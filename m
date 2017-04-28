From: Lance Richardson <lrichard@redhat.com>
Subject: Re: [PATCH net-next] geneve: fix incorrect setting of UDP checksum
 flag
Date: Fri, 28 Apr 2017 14:59:37 -0400 (EDT)
Message-ID: <909853218.2737359.1493405977273.JavaMail.zimbra@redhat.com>
References: <1493327513-23247-1-git-send-email-girish.moodalbail@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, pshelar@ovn.org
To: Girish Moodalbail <girish.moodalbail@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52676 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1425419AbdD1S7i (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 28 Apr 2017 14:59:38 -0400
In-Reply-To: <1493327513-23247-1-git-send-email-girish.moodalbail@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: "Girish Moodalbail" <girish.moodalbail@oracle.com>
> To: davem@davemloft.net
> Cc: netdev@vger.kernel.org, pshelar@ovn.org
> Sent: Thursday, 27 April, 2017 5:11:53 PM
> Subject: [PATCH net-next] geneve: fix incorrect setting of UDP checksum flag
> 
> Creating a geneve link with 'udpcsum' set results in a creation of link
> for which UDP checksum will NOT be computed on outbound packets, as can
> be seen below.
> 
> 11: gen0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN
>     link/ether c2:85:27:b6:b4:15 brd ff:ff:ff:ff:ff:ff promiscuity 0
>     geneve id 200 remote 192.168.13.1 dstport 6081 noudpcsum
> 
> Similarly, creating a link with 'noudpcsum' set results in a creation
> of link for which UDP checksum will be computed on outbound packets.
> 
> Fixes: 9b4437a5b870 ("geneve: Unify LWT and netdev handling.")
> Signed-off-by: Girish Moodalbail <girish.moodalbail@oracle.com>
> ---
>  drivers/net/geneve.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
> index 7074b40..dec5d56 100644
> --- a/drivers/net/geneve.c
> +++ b/drivers/net/geneve.c
> @@ -1244,7 +1244,7 @@ static int geneve_newlink(struct net *net, struct
> net_device *dev,
>  		metadata = true;
>  
>  	if (data[IFLA_GENEVE_UDP_CSUM] &&
> -	    !nla_get_u8(data[IFLA_GENEVE_UDP_CSUM]))
> +	    nla_get_u8(data[IFLA_GENEVE_UDP_CSUM]))
>  		info.key.tun_flags |= TUNNEL_CSUM;
>  
>  	if (data[IFLA_GENEVE_UDP_ZERO_CSUM6_TX] &&
> --
> 1.8.3.1
> 
> 

Verified issue on 4.10.10 kernel. Note that this doesn't impact
lightweight geneve tunnels (e.g. as used by openvswitch).

Acked-by: Lance Richardson <lrichard@redhat.com>
