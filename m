From: BONNEAU Guy <gbonneau@miranda.com>
Subject: RE: Multicast IP packet routed between 2 ports nic on the same host
Date: Tue, 7 Jun 2011 13:57:32 +0000
Message-ID: <24665DDC0D7CF047BD6471A56E615EA628ABF94D@CA-OPS-MAILBOX.miranda.com>
References: <24665DDC0D7CF047BD6471A56E615EA628ABF4DE@CA-OPS-MAILBOX.miranda.com>,<OF6C0FF28D.EF048A18-ON882578A7.0069A85E-882578A7.0069FF2A@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"netdev-owner@vger.kernel.org" <netdev-owner@vger.kernel.org>
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pixmtl-010.148.202.199.miranda.com ([199.202.148.10]:43503 "EHLO
	webmail.miranda.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754585Ab1FGOCj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2011 10:02:39 -0400
In-Reply-To: <OF6C0FF28D.EF048A18-ON882578A7.0069A85E-882578A7.0069FF2A@us.ibm.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Its works! Thanks a lot David! Googling for SO_BINDTODEVICE helped me to get insight into my issue. This link was really useful : http://codingrelic.geekhold.com/2009/10/code-snippet-sobindtodevice.html . However I'm still somewhat confused because I always assumed that this was one of the purpose of IP_ADD_MEMBERSHIP beside joining a multicast group. To constrain the multicast socket to a specific "device" interface. In which case I wonder if the interface member of structure ip_mreq is still relevant? Can you comment!

Thanks
GB

________________________________________
From: David Stevens [dlstevens@us.ibm.com]
Sent: Monday, June 06, 2011 3:17 PM
To: BONNEAU Guy
Cc: netdev@vger.kernel.org; netdev-owner@vger.kernel.org
Subject: Re: Multicast IP packet routed between 2 ports nic on the same host

netdev-owner@vger.kernel.org wrote on 06/06/2011 06:40:26 AM:

> From: BONNEAU Guy <gbonneau@miranda.com>

> I open a second console and I use mreceive to join the same
> multicast group 239.255.200.200:8000 to receive multicast data from
> subnet 172.30.8.xx using the console command : ./mreceive -g 239.
> 255.200.200 -p 8000 -i 172.30.8.31 to the eth1 adapter of my
> workstation. The application starts to receive multicast data and
> advertises the data received. This is also the expected behaviour.
>
> Now this is where the problem begins. As soon as the multicast data
> begin to be received on the eth1 adapter the first console begins to
> advertise multicast data received on eth0 adapter. I am well aware
> that the Linux kernel implements a multicast level 2 routing
> capability. Thus at first glance this seems to be the expected
> behaviour. However... I have forwarding disabled as well as
> mc_forwarding disabled and rp_filter is enabled for both adapters.
> Thus I don't expect the kernel to forward the multicast data from
> eth1 to eth0.

        Routing is between multiple machines. You're receiving the
packets on the sockets because they have a binding that matches.
If you only want to receive multicast packets from a particular
interface, then you need to use "SO_BINDTODEVICE" to restrict to
that interface.
        Group membership is per-interface, but socket bindings match
against any packets delivered to the entire machine, if you haven't
otherwise restricted it.

                                                                +-DLS

