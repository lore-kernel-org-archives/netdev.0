From: Michael Neuling <mikey@neuling.org>
Subject: Re: [PATCH] ehea: add kexec support
Date: Sat, 03 Nov 2007 17:06:31 +1100
Message-ID: <24042.1194069991@neuling.org>
References: <200710261437.29117.ossthema@de.ibm.com> <1193610737.9637.1.camel@concordia> <OF79E7ACE7.5D0488CE-ONC1257384.002E58C0-C1257384.002F8561@de.ibm.com> <1193784636.32504.4.camel@concordia> <OF59B5FFD2.0294206F-ONC1257385.006A802D-C1257385.006CB6BB@de.ibm.com> <1193985008.1782.7.camel@concordia> <OF3FAFDB41.AF236738-ONC1257387.00376233-C1257387.00389861@de.ibm.com>
Cc: michael@ellerman.id.au, Thomas Q Klein <TKLEIN@de.ibm.com>,
	ossthema@linux.vnet.ibm.com, Jeff Garzik <jeff@garzik.org>,
	Jan-Bernd Themann <THEMANN@de.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	Marcus Eder <MEDER@de.ibm.com>,
	Stefan Roscher <stefan.roscher@de.ibm.com>
To: Christoph Raisch <RAISCH@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:38925 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755541AbXKCGGd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 3 Nov 2007 02:06:33 -0400
In-reply-to: <OF3FAFDB41.AF236738-ONC1257387.00376233-C1257387.00389861@de.ibm.com> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Michael Ellerman <michael@ellerman.id.au> wrote on 02.11.2007 07:30:08:
> 
> > On Wed, 2007-10-31 at 20:48 +0100, Christoph Raisch wrote:
> > > Michael Ellerman <michael@ellerman.id.au> wrote on 30.10.2007 23:50:36:
> > If that's really the way it works then eHEA is more or less broken for
> > kdump I'm afraid.
> 
> We think we have a way to workaround this, but let me first try to
> explain the base problem.
> 
> DD allocates HEA resources and gets firmware_handles for these resources.
> To free the resources DD needs to use exactly these handles.
> There's no generic firmware call "clean out all resources".
> Allocating the same resources twice does not work.

Can we get a new firmware call to do this?  

> So a new kernel can't free the resources allocated by an old kernel,
> because the numeric values of the handles aren't known anymore.

How many possible handles are there?  

If the handles are lost, is the only way to clear out the HEA resources
is to reset the partition?

> Potential Solution:
> Hea driver cleanup function hooks into ppc_md.machine_crash_shutdown
> and frees all firmware resources at shutdown time of the crashed kernel.

This means the crashed kernel now has to be trusted to shut down and
free up the resources.  Isn't trusting the crashing kernel in this way
against the whole kdump idea?

> crash_kexec continues and loads new kernel.
> The new kernel restarts the HEA driver within kdump kernel, which will work
> because resources have been freed before.
> 
> Michael, would this work?
> 
> Gruss / Regards
> Christoph R.
> 
> _______________________________________________
> Linuxppc-dev mailing list
> Linuxppc-dev@ozlabs.org
> https://ozlabs.org/mailman/listinfo/linuxppc-dev
> 
