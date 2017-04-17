From: Jay Vosburgh <jay.vosburgh@canonical.com>
Subject: Re: [PATCH net-next v2] bonding: deliver link-local packets with skb->dev set to link that packets arrived on
Date: Mon, 17 Apr 2017 11:28:17 -0700
Message-ID: <14204.1492453697@famine>
References: <20170416190218.57224-1-chonggangli@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: andy@greyhouse.net, vfalico@gmail.com, nikolay@redhat.com,
        edumazet@google.com, davem@davemloft.net, netdev@vger.kernel.org,
        Mahesh Bandewar <maheshb@google.com>,
        =?UTF-8?q?Maciej=20=C5=BBenczykowski?= <maze@google.com>
To: Chonggang Li <chonggangli@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:39179 "EHLO
        youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752107AbdDQS2Z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Apr 2017 14:28:25 -0400
In-reply-to: <20170416190218.57224-1-chonggangli@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chonggang Li <chonggangli@google.com> wrote:

>Bonding driver changes the skb->dev to the bonding-master before
>passing the packet to stack for further processing. This, however
>does not make sense for the link-local packets and it looses "the
>link info" once its skb->dev is changed to bonding-master.  This
>patch changes this behavior for link-local packets by not changing
>the skb->dev to the bonding-master and maintaining it as it is,
>i.e. the link on which the packet arrived.

	Minor nit: "looses" should be "loses".  Other than that:

Signed-off-by: Jay Vosburgh <jay.vosburgh@canonical.com>


>Signed-off-by: Chonggang Li <chonggangli@google.com>
>Signed-off-by: Mahesh Bandewar <maheshb@google.com>
>Signed-off-by: Maciej Żenczykowski <maze@google.com>
>---
>Changes in v2:
>  - Make the commit message more clearer.
>
> drivers/net/bonding/bond_main.c | 3 +++
> 1 file changed, 3 insertions(+)
>
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index 01e4a69af421..6bd3b50faf48 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -1176,6 +1176,9 @@ static rx_handler_result_t bond_handle_frame(struct sk_buff **pskb)
> 		}
> 	}
> 
>+	/* don't change skb->dev for link-local packets */
>+	if (is_link_local_ether_addr(eth_hdr(skb)->h_dest))
>+		return RX_HANDLER_PASS;
> 	if (bond_should_deliver_exact_match(skb, slave, bond))
> 		return RX_HANDLER_EXACT;
> 
>-- 
>2.12.2.762.g0e3151a226-goog
>
