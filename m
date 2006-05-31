From: Auke Kok <sofar@foo-projects.org>
Subject: Re: DPRINTKs in e1000 code (2.6.x kernels)
Date: Wed, 31 May 2006 23:30:23 +0000
Message-ID: <23630a870399173fdc21603d9300d905@localhost>
References: <447D5B51.7030100@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, auke-jan.h.kok@intel.com,
	sofar@foo-projects.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from espresso.foo-projects.org ([193.43.91.203]:11230 "EHLO
	espresso.foo-projects.org") by vger.kernel.org with ESMTP
	id S965259AbWEaXa0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 May 2006 19:30:26 -0400
To: Amit K Arora <aarora@in.ibm.com>
In-Reply-To: <447D5B51.7030100@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Wed, 31 May 2006 14:31:05 +0530, Amit K Arora <aarora@in.ibm.com> wrote:
> Hello,
> 
> I am wondering why this patch "e1000: Remove PM warning DPRINTKs
> breaking 2.4.x kernels"
> (http://www.mail-archive.com/netdev@vger.kernel.org/msg10803.html) was
> meant only for 2.4 kernels, and _not_ for 2.6 kernels.

this code was removed from our generic driver first which is available for 2.4 kernels as well. we try to keep the in-kernel 2.4 and 2.6-driver as close to the general module because we spend a lot of time testing that particular driver.

The removal from the 2.6 kernel has two motivations:
- sync with the standalone tarball driver on e1000.sf.net
- pci subsystem smartness should take care of warning on those operations

> These DPRINTKs in e1000_suspend() are currently resulting in following
> messages while rebooting a system (2.6 kernel) which has e1000 adapter:
> 
> 	Shutting down MD Raid
>     	done
> 	Stopping udevd:                                                      
> 	done
> 	proc umounted
> 	The system will be halted immediately.
> 	md: stopping all md devices.
> 	e1000: eth3: e1000_suspend: Error enabling D3 wake	<<==
> 	e1000: eth3: e1000_suspend: Error enabling D3 cold wake	<<==
> 	Power down.
> 
> 
> Should these DPRINTKs be removed from the 2.6.x e1000 code as well ?

they already are. the patch was merged in 7.0.38-k2 or so which is over a month ago. 

Also, if you are getting these errors there are several fixes in 7.0.38+ in the kernel that might be related. especially the WoL fix that re-enables the shutdown handler correctly might fix this issue for you. Please give this kernel/module a try (see http://www.mail-archive.com/netdev@vger.kernel.org/msg12689.html).

Cheers,

Auke


