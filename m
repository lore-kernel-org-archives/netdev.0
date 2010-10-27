From: Jim <jim876@xs4all.nl>
Subject: Re: tap0 device stopped working in 2.6.36 (ok in 2.6.35)
Date: Wed, 27 Oct 2010 18:09:17 +0200
Message-ID: <4CC84EAD.7040506@xs4all.nl>
References: <4CC2DB2C.3060908@xs4all.nl> <1287862760.7499.225.camel@voxel>	 <4CC40398.6070105@xs4all.nl> <1288142302.26640.7.camel@voxel>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Nolan Leake <nolan@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-vbr4.xs4all.nl ([194.109.24.24]:2489 "EHLO
	smtp-vbr4.xs4all.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752503Ab0J0QJW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Oct 2010 12:09:22 -0400
In-Reply-To: <1288142302.26640.7.camel@voxel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/27/2010 03:18 AM, Nolan Leake wrote:
> On Sun, 2010-10-24 at 11:59 +0200, Jim wrote:
>> Thanks for explaining the purpose of the patch.
>> But it appears something is missing and I think it breaks current
>> userspace. I use this tap0 device together with VirtualBox, I have a
>> virtual machine setup as bridged to tap0, not a very odd or strange
>> setup (this used to be the only method).
>> On the host side I run dhcpd to hand out IP address to the virtual
>> machine, but despite the dhcpd running on the tap0 device it never got
>> 'ready' in the sense that no IP packets made it out from the host to the
>> guest.
> 
> To make sure I understand the situation, is this correct (ignoring the
> exact names of the interfaces):
> br0 bridges between eth0 and tap0, and you run dhcpd on tap0?
> 
> Since tap0 is part of the bridge, I think dhcpd should be running on
> br0.  Does that work?
> 

Not exactly, VirtualBox calls it "bridged adapter", it 'bridges' the
guest machine to the tap0 interface on the host for so called host-only
networking.
See eg. http://forums.virtualbox.org/viewtopic.php?f=1&t=165

And this sequence is now simply failing
  tunctl -t tap0 -u tuxuser
  ifconfig tap0 10.0.0.1 up

Jim
