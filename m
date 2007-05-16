From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] e1000: Fix msi enable leak on error, don't print error
 message,	cleanup
Date: Wed, 16 May 2007 15:16:10 -0400
Message-ID: <464B587A.70804@garzik.org>
References: <20070516083120.23311.3272.stgit@localhost.localdomain>	<464B2426.9060502@garzik.org> <464B504B.5090007@hp.com> <464B55E1.8040501@zytor.com> <464B5734.2070904@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "H. Peter Anvin" <hpa@zytor.com>,
	Auke Kok <auke-jan.h.kok@intel.com>, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:59658 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753152AbXEPTQR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 May 2007 15:16:17 -0400
In-Reply-To: <464B5734.2070904@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rick Jones wrote:
> But that is rather incidental isn't it?  Would some sort of system 
> health monitor be likely to be checking that for interrupt flavors?  And 

Well, that's where the information is exported in a standard way.  I 
hope you're not suggesting that a system health monitor should be 
parsing random, driver-specific printk messages to obtain the same 
information?


> just looking at /proc/interrupts, while it tells you what sort of 
> interrupt is being used, it doesn't (IIRC) say anything about what sort 
> of interrupt the driver _tried_ to use.

True.

In the context of this thread, it could be any number of reasons:  MSI 
isn't compiled in.  MSI was disabled at runtime via kernel command line. 
  MSI was disabled by BIOS quirk.  MSI enable was attempted, but failed 
for some reason.

None of those reasons are really driver-specific, or need 
driver-specific complaint messages.

	Jeff


