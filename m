From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: Re: [E1000-devel] behaviour question for igb on nehalem box
Date: Fri, 16 Oct 2009 15:48:18 -0700 (Pacific Daylight Time)
Message-ID: <alpine.WNT.2.00.0910161544330.13364@jbrandeb-mobl2.amr.corp.intel.com>
References: <4ACF8466.5030309@nortel.com> <alpine.WNT.2.00.0910091250440.5328@jbrandeb-desk1.amr.corp.intel.com> <4ACFB9DF.9080909@nortel.com> <4ACFC52F.4050509@intel.com> <4ACFCBE8.7060108@intel.com> <4AD4B9BB.3010209@nortel.com>
 <4AD8F089.9010602@sauce.co.nz>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Chris Friesen <cfriesen@nortel.com>,
	e1000-list <e1000-devel@lists.sourceforge.net>,
	Linux Network Development list <netdev@vger.kernel.org>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"gospo@redhat.com" <gospo@redhat.com>
To: Richard Scobie <richard@sauce.co.nz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:47395 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751116AbZJPWsP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Oct 2009 18:48:15 -0400
In-Reply-To: <4AD8F089.9010602@sauce.co.nz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 16 Oct 2009, Richard Scobie wrote:
> I'm have just put together a Nehalem system (1 x Xeon), 
> 2.6.30.8-64.fc11.x86_64, which has quad onboard 82576 and noticed during 
> testing using just a single interface, that the RX queues on the other 3 
> were receiving interrupts - observed in /proc/interrupts.
> 
> Is this normal behaviour?

Hi Richard, 

This is normal, since we trigger an interrupt on every queue during our 
watchdog.  So if the interface is up it should be triggering an interrupt 
on every queue every two seconds.

This has (and will probably continue to be) necessary in order to pick up 
any straggler packets due to any (extremely rare, but expected to occur) 
missed interrupts that could happen when traffic is running.  It also is 
extremely useful if you're doing irq affinitization and/or debugging 
interrupts.

you can bring down the interfaces and they will stop interrupting.

Jesse
