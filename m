From: Christian Borntraeger <borntraeger@de.ibm.com>
Subject: Re: Multicast and receive filtering in TUN/TAP
Date: Thu, 10 Jul 2008 10:29:17 +0200
Message-ID: <200807101029.17121.borntraeger@de.ibm.com>
References: <4875428F.4080704@qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Max Krasnyansky <maxk@qualcomm.com>,
	Brian Braunstein <linuxkernel@bristyle.com>,
	Shaun Jackman <sjackman@gmail.com>, netdev@vger.kernel.org,
	Rusty Russell <rusty@rustcorp.com.au>
To: virtualization@lists.linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.uk.ibm.com ([195.212.29.135]:3219 "EHLO
	mtagate2.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751525AbYGJI3n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2008 04:29:43 -0400
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate2.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m6A8TJED184786
	for <netdev@vger.kernel.org>; Thu, 10 Jul 2008 08:29:19 GMT
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m6A8TJoQ2183196
	for <netdev@vger.kernel.org>; Thu, 10 Jul 2008 09:29:19 +0100
Received: from d06av04.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m6A8TIpf023754
	for <netdev@vger.kernel.org>; Thu, 10 Jul 2008 09:29:19 +0100
In-Reply-To: <4875428F.4080704@qualcomm.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Donnerstag, 10. Juli 2008 schrieb Max Krasnyansky:
[...]
> The second question is do you guys think that QEMU/KVM/LGUEST/etc would 
> benefit if receive filtering was done by the host OS. Here is a specific 
> example of what I'm talking about.
> We can do what qemu/hw/e1000.c:receive_filter() does in the _host_ 
> context (that function currently runs in the guest context). By looking 
> at libvirt, typical QEMU based setup is that you have a single bridge 
> and all the TAPs from different VMs are hooked up to that bridge. What 
> that means is that if one VM is getting MC traffic or when the bridge 
> sees MACADDR that is not in its tables the packets get delivered to all 
> the VMs. ie We have to wake all of the up only to so that they could 
> drop that packet. Instead, we could setup filters in the host's side of 
> the TAP device.
> Does that sound like something useful for QEMU/KVM ?
> If yes we can talk about the API. If not then I'll just nuke it.

Max,

I know that on s390 the shared OSA network card have multicast filter 
capabilities. So I guess it is worthwile for a virtualization environments 
with lots of guests. I also think, that this kind of filtering should be 
straightforward to implement with the qemu e1000 code. Qemu already knows the 
multicast addresses.

Thing is, we are heading towards virtio. Unfortunately, virtio_net currently 
does not offer a method to register multicast addresses.

Rusty, do you think its worthwile to notify the host about registered 
multicast addresses?

Christian
