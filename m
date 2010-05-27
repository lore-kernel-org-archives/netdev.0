From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [RFC] IFLA_PORT_* iproute2 cmd line
Date: Thu, 27 May 2010 09:00:29 +0200
Message-ID: <201005270900.29776.arnd@arndb.de>
References: <C8228316.35508%scofeldm@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Chris Wright <chrisw@redhat.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Stefan Berger <stefanb@us.ibm.com>,
	Dirk Herrendoerfer <d.herrendoerfer@de.ibm.com>,
	Vivek Kashyap <vivk@us.ibm.com>
To: Scott Feldman <scofeldm@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.10]:49736 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750967Ab0E0HAu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 May 2010 03:00:50 -0400
In-Reply-To: <C8228316.35508%scofeldm@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 26 May 2010, Scott Feldman wrote:
> On 5/26/10 5:38 AM, "Arnd Bergmann" <arnd@arndb.de> wrote:
> 
> How does this strike you?
> 
>   Usage: ip link add link DEV [ name ] NAME
>                      [ txqueuelen PACKETS ]
>                      [ address LLADDR ]
>                      [ broadcast LLADDR ]
>                      [ mtu MTU ]
>                      type TYPE [ ARGS ]
>          ip link delete DEV type TYPE [ ARGS ]
> 
>          ip link set DEVICE [ { up | down } ]
>                             [ arp { on | off } ]
>                             [ dynamic { on | off } ]
>                             [ multicast { on | off } ]
>                             [ allmulticast { on | off } ]
>                             [ promisc { on | off } ]
>                             [ trailers { on | off } ]
>                             [ txqueuelen PACKETS ]
>                             [ name NEWNAME ]
>                             [ address LLADDR ]
>                             [ broadcast LLADDR ]
>                             [ mtu MTU ]
>                             [ netns PID ]
>                             [ alias NAME ]
> +                           [ virtualport MODE {PROFILE|VSI} ]
>                             [ vf NUM [ mac LLADDR ]
>                                      [ vlan VLANID [ qos VLAN-QOS ] ]
> -                                    [ rate TXRATE ] ]
> +                                    [ rate TXRATE ]
> +                                    [ virtualport MODE {PROFILE|VSI} ] ]
>          ip link show [ DEVICE ]
> 
>   TYPE := { vlan | veth | vcan | dummy | ifb | macvlan | can }
> +
> + MODE := { associate | preassociate | preassociaterr | disassociate }
> +
> + PROFILE := port-profile PORT-PROFILE
> +            [ instance-uuid INSTANCE-UUID ]
> +            [ host-uuid HOST-UUID ]
> + 
> + VSI := vsi managerid MGR typeid VTID typeidversion VER
> +        [ instance-uuid INSTANCE-UUID ]

Right, exactly what I was thinking of. I would probably use
some shorter keywords (virtual-port -> port, port-profile -> profile,
instance-uuid -> instance, host-uuid -> host), but I really
don't have a strong opionion on that, so I'f fine with
whatever you and others come up with in that regard.

> > The more interesting question is how to do this when we
> > talk to lldpad. One idea was to use the same protocol
> > but to direct the message to a specific pid (that of lldpad).
> > That would require adding an option like '-p PID' to ip
> > that lets us change who we talk to.
> 
> Let me get the user-to-kernel part working to establish the cmd line and you
> can follow up with alternative addressing schemes.

ok.

	Arnd
