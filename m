From: "Rask Ingemann Lambertsen" <rask@sygehus.dk>
Subject: Re: [EXPERIMENTAL PATCH] 2.4 tulip jumbo frames
Date: Wed, 10 Dec 2003 00:40:02 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031209224906.M53356@sygehus.dk>
References: <20031209160632.D1345@sygehus.dk> <3FD5FC36.5090405@pobox.com> <20031209223214.A1855@sygehus.dk> <3FD64EC9.6010203@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <3FD64EC9.6010203@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 09 Dec 2003 14:38:01 -0800, Ben Greear wrote
> Rask Ingemann Lambertsen wrote:
> 
> > What do you propose? Do we need something like
> > 
> > int vlan_adjust_mtu (int mtu)
> > {
> > #ifdef CONFIG_VLANN_8021Q
> > 	return (mtu - VLAN_HLEN);
> > #else
> > 	return (mtu);
> > #endif
> > }
> I was thinking the check could be made run-time, but in reality, 
> this is a very minor detail.

You could use something like

        if (dev->priv_flags & IFF_802_1Q_VLAN)
                return (mtu - VLAN_HLEN);
        else
                return (mtu);

but then you have a problem if the MTU is set to the maximum with VLAN 
disabled and someone decides to enable VLAN on the device afterwards. A 
possible solution would be to set NETIF_F_VLAN_CHALLENGED when VLAN_HLEN
extra bytes are not available.

That said, even checking CONFIG_VLAN_8021Q is probably flawed too, because 
ideally, even when building a kernel without VLAN support, you should be able 
to use the bridging support in a VLAN environment. IMHO. I mean, if this is 
not the case, please remind me why we need VLAN patches in the first place 
since setting an MTU of 1496 bytes works with every Ethernet board and driver.

> I don't like the patch above, I'd rather see the
> #ifdef when checking for the maximum hardware limit, if anywhere.

I was thinking that there could be other reasons than VLAN for reducing the 
MTU and that vlan_adjust_mtu() could take these into account as well. PPPoE 
comes to my mind, but I have no clue how that is implemented in Linux (or any 
other system).

-- 
Regards,
Rask Ingemann Lambertsen
