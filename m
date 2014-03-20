From: "Ertman, DavidX M" <davidx.m.ertman@intel.com>
Subject: RE: [E1000-devel] i217-LM boot wreckage
Date: Thu, 20 Mar 2014 15:12:48 +0000
Message-ID: <2B0E3F215D1AB84DA946C8BEE234CCC9370CEFE3@ORSMSX101.amr.corp.intel.com>
References: <alpine.DEB.2.02.1403201332400.18573@ionos.tec.linutronix.de>
 <alpine.DEB.2.02.1403201431580.18573@ionos.tec.linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
To: Thomas Gleixner <tglx@linutronix.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:6804 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757056AbaCTPPa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2014 11:15:30 -0400
In-Reply-To: <alpine.DEB.2.02.1403201431580.18573@ionos.tec.linutronix.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Thomas,

Could you provide the exact kernel version and kernel config you are using?
Do you have Runtime Power Management enabled?
Have you tried the latest driver from sourceforge.net (3.0.4.1)?

>From your lspci output it looks like you have a Management Engine enabled platform.   Do you know what version of ME is loaded?  Have you checked to see that you are on the latest BIOS/NVM image (looks like a new one was released on March 11th for the M93z)?

Thanks

-----Original Message-----
From: Thomas Gleixner [mailto:tglx@linutronix.de] 
Sent: Thursday, March 20, 2014 6:45 AM
To: netdev@vger.kernel.org
Cc: e1000-devel@lists.sourceforge.net
Subject: Re: [E1000-devel] i217-LM boot wreckage

On Thu, 20 Mar 2014, Thomas Gleixner wrote:
> So it looks like the BIOS is setting something up, when the cable is 
> plugged at power on time, which is not visible through our debug 
> output.

Some more info:

I prevented e1000e from being autoloaded and booted with the cable unplugged.

T1:
  Plug cable 
  modprobe e1000e	-> Works

T2:
  modprobe e1000e
  plug cable		-> Works not

  rmmod e1000e
  modprobe e1000e	-> works not

  unplug cable
  rmmod e1000e
  modprobe e1000e	-> works

  rmmod e1000e
  unplug cable     
  modprobe e1000e
  plug cable		-> Works not

  rmmod e1000e
  unplug cable     
  plug cable
  modprobe e1000e	-> Works not

So if the module is loaded w/o the cable plugged it does not work. If I unplug before unloading the module and then plug in before loading the module again it works again.

Thanks,

	tglx


------------------------------------------------------------------------------
Learn Graph Databases - Download FREE O'Reilly Book "Graph Databases" is the definitive new guide to graph databases and their applications. Written by three acclaimed leaders in the field, this first edition is now available. Download your free book today!
http://p.sf.net/sfu/13534_NeoTech
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
