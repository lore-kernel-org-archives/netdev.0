From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH/RFC] disallow vlan devices on top of a logical bridge
 device
Date: Sat, 30 Aug 2003 12:46:22 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F50FF0E.9020004@candelatech.com>
References: <200308301504.03241.bdschuym@pandora.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S.Miller" <davem@redhat.com>,
   Stephen Hemminger <shemminger@osdl.org>, netdev@oss.sgi.com,
   vlan@wanfear.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Bart De Schuymer <bdschuym@pandora.be>
In-Reply-To: <200308301504.03241.bdschuym@pandora.be>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Bart De Schuymer wrote:
> Hi all,
> 
> The patch below disables making vlan devices on top of bridge
> devices, f.e. br0.12 would be impossible.
> I'm no vlan expert, but I don't see the use for this and allowing it
> will make the bridge-nf code hairy if we want to let {ip,arp}tables see
> {IP,ARP} traffic that is embedded in a vlan header.
> Also, situations like eth0.15 being a bridge port of br0.16 seem
> unwanted (to me).
> Dave, please apply, unless someone more knowledgeable (than me) about
> this disagrees.

I have never tried to do this, so I don't have a problem with this patch.

However, I'm forwarding this to the vlan mailing list, as I know there
are folks there who use vlans and bridging a lot....  For those who
care, please speak up if you need this functionality for some reason...

Ben

> 
> cheers,
> Bart
> 
> --- linux-2.6.0-test4/net/bridge/br_if.c.old	2003-08-30 13:51:26.000000000 +0200
> +++ linux-2.6.0-test4/net/bridge/br_if.c	2003-08-30 14:38:58.000000000 +0200
> @@ -98,6 +98,8 @@ static struct net_bridge *new_nb(const c
>  	if (!dev)
>  		return NULL;
>  
> +	dev->features |= NETIF_F_VLAN_CHALLENGED;
> +	
>  	br = dev->priv;
>  	br->dev = dev;
>  
> 


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
