From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH net] vxlan: revert per-vxlan port
Date: Thu, 23 May 2013 16:06:03 -0400
Message-ID: <OFD1F52E5E.B02C16A0-ON85257B74.006AF452-85257B74.006E6AF1@us.ibm.com>
References: <20130520103017.054ae605@nehalam.linuxnetplumber.net>	<OFECE722DE.3DBEE821-ON85257B71.00610478-85257B71.006456B5@us.ibm.com>
	<20130520113000.0057ce90@nehalam.linuxnetplumber.net>	<20130522.150830.1305371698781503084.davem@davemloft.net>
	<OFB688A387.A3698315-ON85257B73.007C1B7B-85257B73.00800294@us.ibm.com>	<20130522173954.7f75f62d@nehalam.linuxnetplumber.net>
	<OF0BD0286F.81969B78-ON85257B74.00097DBA-85257B74.000C5443@us.ibm.com>	<20130523100854.6c9749d6@nehalam.linuxnetplumber.net>
	<OFCF66B423.CF0815E9-ON85257B74.0062F5C7-85257B74.0067134F@us.ibm.com> <20130523121804.6b7450a3@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e38.co.us.ibm.com ([32.97.110.159]:58986 "EHLO
	e38.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758612Ab3EWUGY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 May 2013 16:06:24 -0400
Received: from /spool/local
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <dlstevens@us.ibm.com>;
	Thu, 23 May 2013 14:06:23 -0600
In-Reply-To: <20130523121804.6b7450a3@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <stephen@networkplumber.org> wrote on 05/23/2013 
03:18:04 PM:

 
> With the patch davem already included, the dstport is enough
> to add additional listener.

        If you're saying that using the dstport changes the
listen port, or adds another listen port, then I think that
behaviour is wrong and should be reverted.
        An admin should be able to specify the source and destination
ports independently of each other. If dstport has a side-effect that
is unrelated to changing the destination port, that's what I'd call
"confusing."
        IMHO, "port" should change the listen port (only) and "dstport"
should change the send port (only). And yes, both of those should allow
multiple ports, and destinations. So, binding should be a list of
the form: "[IP:]port[,[IP:]port]*" and destinations should be the same
as in the fdb, allowing multiple destinations and different ports, and
different vni's. It should be simply a "default" fdb entry in all 
respects.

> Another use case is:
>  # ip link add vxlan-old type vxlan id 42 group 239.1.1.1 dev eth0
>  # ip link add vxlan-new type vxlan id 42 group 239.1.1.1 dev eth0 
> dstport 4789
> 
> This also works with net-next and not with 3.10

        Yes, I wholeheartedly approve of this feature. It simply is
not the only use case for wanting different destination ports, so is
not linked to the dstport feature, in my opinion.

> > If I have two existing systems, one listening on port 8472 and one 
> > listening
> > on port 4789, and I want to connect them, how would you do that?
> 
> You can either do:
>  A. Define two vxlan's and route or bridge them
>  B. Define one vxlan with a destination port and add exception FDB entry
>     to talk to the outlier

        So, you're requiring an extra bind port (and the specific port the
remote device is using may not be available on the local machine) and an
extra hop through a bridge, when all you really want as an admin is to say
"listen on this port, send on that port" without that also meaning you
have to know and specify the MAC address of every possible remote VM.

> User's may reasonably want to define multiple overlay VXLAN's each
> on a different port, or create one VXLAN and add excptions.

        Sure. I think multiple listen ports is a good idea, but it is
not the only reason for wanting a different destination port, and not
a reason to link destination and listen ports.
 
> The dstport option is not in a released kernel or iproute.

I don't think we're going to get consensus here. If you intend the
artificial requirement that the bind and listen ports be the same,
and that admins need to jump through hoops to get the reasonable
effect of making them different, then I simply disagree with you.

                                                                +-DLS
