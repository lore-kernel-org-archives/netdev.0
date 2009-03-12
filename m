From: Christer Weinigel <christer@weinigel.se>
Subject: Re: [PATCH] dnet: Dave DNET ethernet controller driver
Date: Thu, 12 Mar 2009 20:21:18 +0100
Message-ID: <49B960AE.6050502@weinigel.se>
References: <49B91A7B.7050303@weinigel.se> <20090312151211.GB24995@hmsreliant.think-freely.org> <49B93777.7030202@weinigel.se> <20090312.104345.68580544.davem@davemloft.net> <49B94BCA.6090309@weinigel.se> <20090312180638.GG14491@shareable.org> <49B95907.4010404@weinigel.se> <20090312190416.GS425@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Christer Weinigel <christer@weinigel.se>,
	Jamie Lokier <jamie@shareable.org>,
	David Miller <davem@davemloft.net>, nhorman@tuxdriver.com,
	shemminger@vyatta.com, yanok@emcraft.com,
	lin
Return-path: <netdev-owner@vger.kernel.org>
Received: from 2-1-3-15a.ens.sth.bostream.se ([82.182.31.214]:34305 "EHLO
	zoo.weinigel.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754496AbZCLTVY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2009 15:21:24 -0400
In-Reply-To: <20090312190416.GS425@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sascha Hauer wrote:
>> That would be a very worthwhile project actually.  Create a package that  
>> uses klibc, does BOOTP/DCHP/NFS and parses the the ip=foo,bar options  
>> the same way the kernel does so that we can finally get rid of the in  
>> kernel stuff.
> 
> Great, but how does this help in setting the MAC address? This would
> just move this exact discussion to the dracut or whatever mailing list,
> but we would still be searching for a generic way to say
> eth0addr=00:01:02:03:04:05 and I bet the arguments stay the same.

Alternate answers:

a) It wouldn't.  But that doesn't stop me from liking the idea of 
actually having a working initrd/initramfs that people can build on.

b) It would.  With an easy to use initrd/initramfs infrastructure it 
would be trivial to add a small script that parses /proc/cmdline and 
runs "ifconfig eth0 hwaddr $FOO" based on it.

c) It would.  When the initrd/initramfs runs, it has access to all the 
normal device driver, so reading the first block of flash and parsing 
the non-volatile data (assuming there is a mts device driver and that 
the format is known) and then running ifconfig eth0 hwaddr is also much 
easier.

And personally, yes, if there was a working initrd+dhcp+nfs combination 
that doesn't require significantly more memory than the in kernel one, 
of course I would use it.  And that's what DaveM is suggesting, to keep 
it out of the kernel and move it to user space where it really belongs.

Short therm I'd still like to have the more generic thing in the kernel 
tough.

   /Christer



