From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: Multicast IP packet routed between 2 ports nic on the same host
Date: Mon, 6 Jun 2011 12:17:47 -0700
Message-ID: <OF6C0FF28D.EF048A18-ON882578A7.0069A85E-882578A7.0069FF2A@us.ibm.com>
References: <24665DDC0D7CF047BD6471A56E615EA628ABF4DE@CA-OPS-MAILBOX.miranda.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	netdev-owner@vger.kernel.org
To: BONNEAU Guy <gbonneau@miranda.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:56265 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757783Ab1FFTSL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2011 15:18:11 -0400
In-Reply-To: <24665DDC0D7CF047BD6471A56E615EA628ABF4DE@CA-OPS-MAILBOX.miranda.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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

