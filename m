From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] dnet: Dave DNET ethernet controller driver
Date: Thu, 12 Mar 2009 20:21:55 -0400
Message-ID: <20090313002155.GB13764@localhost.localdomain>
References: <49B8E6D4.2030702@weinigel.se> <20090312.055523.193191701.davem@davemloft.net> <49B91A7B.7050303@weinigel.se> <20090312151211.GB24995@hmsreliant.think-freely.org> <49B93777.7030202@weinigel.se> <20090312174933.GC24995@hmsreliant.think-freely.org> <49B95386.2030600@weinigel.se> <20090312190517.GD24995@hmsreliant.think-freely.org> <20090312215919.GA19200@shareable.org> <49B99DF1.9000509@weinigel.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamie Lokier <jamie@shareable.org>,
	David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	s.hauer@pengutronix.de, yanok@emcraft.com,
	linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org,
	wd@denx.de, dzu@denx.de
To: Christer Weinigel <christer@weinigel.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:46596 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752072AbZCMAWR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2009 20:22:17 -0400
Content-Disposition: inline
In-Reply-To: <49B99DF1.9000509@weinigel.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 13, 2009 at 12:42:41AM +0100, Christer Weinigel wrote:
> Jamie Lokier wrote:
>
>> Neil Horman wrote:
>>> I've not looked at the figures lately, but how much space does the
>>> dhcp client and nfs root code take up in the kernel these days?
>>
>> About 4k apparently.  See the difference from "400k compressed?".
>> Also, uncompressing that may add 0.5 second boot time on a slow CPU :-)
>
>
> I just tried to get some actual numbers for the size increase by looking  
> at an actual initrd I had lying around.  If I just look at some some of  
> the largest files needed for a initrd, they use 800kBytes:
>
> ls -l bin/busybox lib/ld-uClibc-0.9.28.so lib/libuClibc-0.9.28.so
> -rwxr-xr-x 1 root root 499804 2007-01-21 18:17 bin/busybox*
> -rwxr-xr-x 1 root root  19492 2005-12-27 12:15 lib/ld-uClibc-0.9.28.so*
> -rw-r--r-- 1 root root 312136 2005-12-27 08:46 lib/libuClibc-0.9.28.so
>
> All files are stripped ARM9 binaries and as you can see, the C library  
> is uClibc.  And compressed it is roughly about 400kBytes:
>
> tar cvfz - bin/busybox lib/ld-uClibc-0.9.28.so lib/libuClibc-0.9.28.so | wc -c
>
> 422789
>
> The in kernel BOOT/DCHP client and NFS root code increases the size of
> the compressed kernel by slighty less than 8kBytes.  The 4k number was
> just for turning off BOOTP/DHCP (IP_PNP).
>
> > I must admit that a solution which makes the effective kernel size
>
>> 800k larger (your figure) doesn't look like a good standard to me.
>>
>> If that was the "standard", I'd be tempted to add a MAC address driver
>> hack to the kernel to save the space :-)
>
> So the numbers aren't quite as bad, but it is a 50 time increase in  
> overhead to do things "right".  For a kernel which is 1.5Mbytes it is  
> "only" a 27% increase in total size though.
>
> Of course, using busybox is a bit of an overkill, it should be possible  
> to just port the in kernel BOOTP/DHCP client and NFS root code so that  
> it is statically linked with klibc and put in an initrd.  If we assume  
> that the useful parts of the code stay the same size, it should compress  
> to about 8kBytes of initrd instead of 8kBytes of compressed kernel  
> image.  But code running from an initrd will need a stdio library with  
> printf and a bunch of other library functions.  After taking a quick  
> look at klibc it seems that it would add something like 10-20kBytes  
> compressed size to a normal application.  So that would only be a 2-3  
> time increase in size which is much more acceptable to me.
>
> Actually, just looking at the filenames in the klibc source, it seems  
> that it does have a DHCP client and some NFS root code already.  An ARM9  
> "kinit" binary is about 75kBytes, and I'm not sure if it includes the  
> DHCP client or the NFS root code.  But it means that it's probably  
> possible to replace the in kernel code with klibc as is for only an  
> extra 50kBytes or so of increased compressed size.
>
> Looks interesting, any year now...
>
>   /Christer
>

So, I've avoided asking this question, because I didn't want to get off topic,
but since it appears we're winding up here, I have to ask what your long term
plan is for your final application.  I can understand being hesitant to invest
in an initramfs when its solely for your intermediate development (even though I
think that will pay off for you in the long run), but when your development
ends, and you ship a product, how do you plan to implement your application?  I
would imagine you at least need an initramfs to store, load and run your final
application don't you?  How do you plan on executing it?

Neil

>
>
>
>
>
>
>
>
>
>
>
>
>
>
