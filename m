From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH net-next 2/6] bonding: remove the no effect lock for bond_3ad_lacpdu_recv()
Date: Fri, 30 Aug 2013 10:07:38 -0700
Message-ID: <5220D15A.1070308@hp.com>
References: <52206E3F.6090007@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Netdev <netdev@vger.kernel.org>
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0015.houston.hp.com ([15.201.24.18]:38119 "EHLO
	g4t0015.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753547Ab3H3RHk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Aug 2013 13:07:40 -0400
In-Reply-To: <52206E3F.6090007@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/30/2013 03:04 AM, Ding Tianhong wrote:
> There is no pointer needed read lock protection, remove the unnecessary lock
> and improve performance for the 3ad recv path.

Improve performance by how much?  For example, by how much is service 
demand lower on a netperf TCP_STREAM or TCP_RR test through a bond.  I 
suppose that applies not only to this specific patch to to the set as a 
whole.

rick jones


>
> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
> Cc: Nikolay Aleksandrov <nikolay@redhat.com>
> ---
>   drivers/net/bonding/bond_3ad.c | 2 --
>   1 file changed, 2 deletions(-)
>
> diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
> index 7a3860f..c134f43 100644
> --- a/drivers/net/bonding/bond_3ad.c
> +++ b/drivers/net/bonding/bond_3ad.c
> @@ -2494,9 +2494,7 @@ int bond_3ad_lacpdu_recv(const struct sk_buff *skb, struct bonding *bond,
>   	if (!lacpdu)
>   		return ret;
>
> -	read_lock(&bond->lock);
>   	ret = bond_3ad_rx_indication(lacpdu, slave, skb->len);
> -	read_unlock(&bond->lock);
>   	return ret;
>   }
>
>
