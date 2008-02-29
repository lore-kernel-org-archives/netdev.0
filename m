From: James Chapman <jchapman@katalix.com>
Subject: Re: Network device driver with PPP
Date: Fri, 29 Feb 2008 15:02:52 +0000
Message-ID: <47C81E9C.4050903@katalix.com>
References: <3415E2A2AB26944B9159CDB22001004D024DA732@nestea.sierrawireless.local> <1204164955.26292.5.camel@localhost.localdomain> <47C67E67.70604@katalix.com> <3415E2A2AB26944B9159CDB22001004D024DA7DC@nestea.sierrawireless.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Dan Williams <dcbw@redhat.com>, netdev@vger.kernel.org
To: Kevin Lloyd <klloyd@sierrawireless.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s36.avahost.net ([74.53.95.194]:34380 "EHLO s36.avahost.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932208AbYB2PDF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Feb 2008 10:03:05 -0500
In-Reply-To: <3415E2A2AB26944B9159CDB22001004D024DA7DC@nestea.sierrawireless.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kevin Lloyd wrote:
>> That seems quite icky to do all in kernel space and a pile of code
>> running in the kernel.  What's so wrong with userspace?  Don't you
> need
>> to push values to the driver like username/password and get IP config
>> out of it (which would involve userspace anyway)?  It just seems like
>> there's a different solution to your actual problem here than stuff
> all
>> off pppd into kernel space.
> 
> Actually we provide a method for the driver to obtain the
> username/password information needed for the CHAP authentication so in
> theory the driver has the information needed to create the connection.
> I'm not sure how it would go about setting the DNS and IP addresses, but
> that's a separate issue further down the road.

Can you explain why you need the driver to be involved in any of this?

> I understand that typical implementation is to deal with ppp
> negotiations in the userspace however are there no devices that have
> attempted this in the kernel space / no kernel space modules to aid with
> this? 

No.

Control protocols live in userspace, datapath in the kernel.

> Just trying to do a full investigation of all available options,
> even if they aren't the best ones.

> If not, is there a method for the network driver to launch pppd with a
> given set of parameters (not using udev) since the driver would be
> determining username/password runtime.

Can't you implement a private interface to your kernel driver so that 
userspace can ask it for the username/password and userspace then starts 
pppd with those parameters?


-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

