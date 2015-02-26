From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: Re: [PATCH net-next 2/7] net: bluetooth: compact struct bt_skb_cb
 by converting boolean fields to bit fields
Date: Thu, 26 Feb 2015 09:30:41 +0200
Message-ID: <20150226093041.5cac2141@halley>
References: <1424916612-744-1-git-send-email-eyal.birger@gmail.com>
	<1424916612-744-3-git-send-email-eyal.birger@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, willemb@google.com, edumazet@google.com,
	marcel@holtmann.org, netdev@vger.kernel.org
To: Eyal Birger <eyal.birger@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f53.google.com ([74.125.82.53]:35868 "EHLO
	mail-wg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751217AbbBZHas (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 02:30:48 -0500
Received: by wghk14 with SMTP id k14so8293585wgh.3
        for <netdev@vger.kernel.org>; Wed, 25 Feb 2015 23:30:47 -0800 (PST)
In-Reply-To: <1424916612-744-3-git-send-email-eyal.birger@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 26 Feb 2015 04:10:07 +0200 Eyal Birger <eyal.birger@gmail.com> wrote:
> @@ -277,11 +277,11 @@ typedef void (*hci_req_complete_t)(struct hci_dev *hdev, u8 status, u16 opcode);
>  
>  struct bt_skb_cb {
>  	__u8 pkt_type;
> -	__u8 incoming;
>  	__u16 opcode;
>  	__u16 expect;
> -	__u8 force_active;
> -	bool req_start;
> +	__u8 force_active:1;
> +	__u8 incoming:1;
> +	__u8 req_start:1;
>  	u8 req_event;
>  	hci_req_complete_t req_complete;
>  	struct l2cap_chan *chan;

There's a:
    bt_cb(skb)->force_active = BT_POWER_FORCE_ACTIVE_ON;
assignment in l2cap_core.c.

No bluetooth expert, no idea if BT_POWER_FORCE_ACTIVE_ON is 1 by definition.
If not, maybe prefer:
    bt_cb(skb)->force_active = !!BT_POWER_FORCE_ACTIVE_ON

Besides that,
Reviewed-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>
