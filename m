From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: A question about include/linux/socket.h
Date: Wed, 28 Aug 2013 15:27:35 +0100
Message-ID: <1377700055.2264.11.camel@bwh-desktop.uk.level5networks.com>
References: <521DFEF9.5040701@linkas.com.tr>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Sinan Akpolat <sinan@linkas.com.tr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:39761 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752736Ab3H1O1j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Aug 2013 10:27:39 -0400
In-Reply-To: <521DFEF9.5040701@linkas.com.tr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-08-28 at 16:45 +0300, Sinan Akpolat wrote:
> Hi,
> 
> I am writing CAN bus userspace code and I get a compiler error stating 
> "sa_family_t is not defined" for "include/linux/can.h". sa_family_t is 
> defined in include/linux/socket.h but it is not carried to userspace 
> kernel headers.
> 
>   When I searched about it I saw that a similar problem in 
> include/linux/netlink.h and include/linux/socket.h is fixed by the patch:
> 
> https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/include?id=6602a4baf4d1a73cc4685a39ef859e1c5ddf654c. 

You probably want commit bcb949b8847655516ba499ca75cd8529f167e360, which
fixed include/linux/can.h.

> I also read about UAPI but I can't use newer kernels.
> 
> I searched the kernel git repo but couldn't find a similar patch for 
> can.h. When you search for "sa_family_t" in include/linux directory you 
> can see it is used in more than 10 files and I guess none of those files 
> will compile since they won't be able to find typedef sa_family_t (just 
> like can.h).
> 
> So my question is:
> - Does anyone remember a patch fixing this issue?
> - Should the typedef sa_family_t moved to userspace kernel headers? Or 
> should structs containing sa_family_t type variables moved away from 
> user space?

No, sa_family_t is normally defined by the C library headers.  But
kernel headers generally don't include those (for good reasons).  So
kernel headers should instead define and use __kernel_sa_family_t, and
that's what they do now (mostly).

Ben.

> I have been using the file manually defining sa_family_t but I wanted to 
> ask. I am using kernel version 2.6.37 but I guess can.h file was 
> unchanged until 3.5.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
