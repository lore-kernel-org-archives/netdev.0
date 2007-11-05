From: Christoph Raisch <RAISCH@de.ibm.com>
Subject: Re: [PATCH] ehea: add kexec support
Date: Mon, 5 Nov 2007 15:24:13 +0100
Message-ID: <OF46AA6850.8C031396-ONC125738A.004D7626-C125738A.004F05C8@de.ibm.com>
References: <200710261437.29117.ossthema@de.ibm.com> <1193610737.9637.1.camel@concordia> <OF79E7ACE7.5D0488CE-ONC1257384.002E58C0-C1257384.002F8561@de.ibm.com> <1193784636.32504.4.camel@concordia> <OF59B5FFD2.0294206F-ONC1257385.006A802D-C1257385.006CB6BB@de.ibm.com> <1193985008.1782.7.camel@concordia> <OF3FAFDB41.AF236738-ONC1257387.00376233-C1257387.00389861@de.ibm.com> <24042.1194069991@neuling.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Jan-Bernd Themann <THEMANN@de.ibm.com>,
	Jeff Garzik <jeff@garzik.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	Marcus Eder <MEDER@de.ibm.com>, michael@ellerman.id.au,
	netdev <netdev@vger.kernel.org>, ossthema@linux.vnet.ibm.com,
	Stefan Roscher <stefan.roscher@de.ibm.com>,
	Thomas Q Klein <TKLEIN@de.ibm.com>
To: Michael Neuling <mikey@neuling.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.de.ibm.com ([195.212.29.155]:51399 "EHLO
	mtagate6.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754986AbXKEOYE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Nov 2007 09:24:04 -0500
In-Reply-To: <24042.1194069991@neuling.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Michael Neuling <mikey@neuling.org> wrote on 03.11.2007 07:06:31:

> > DD allocates HEA resources and gets firmware_handles for these
resources.
> > To free the resources DD needs to use exactly these handles.
> > There's no generic firmware call "clean out all resources".
> > Allocating the same resources twice does not work.
>
> Can we get a new firmware call to do this?

Well, there's no simple answer to this. I'm not working on firmware.
I'm trying to get an answer... but don't expect anything "real soon".

>
> > So a new kernel can't free the resources allocated by an old kernel,
> > because the numeric values of the handles aren't known anymore.
>
> How many possible handles are there?

Depends on system configuration, between
4 and 64 per port.

>
> If the handles are lost, is the only way to clear out the HEA resources
> is to reset the partition?

Yes, that's exactly the problem.

>
> > Potential Solution:
> > Hea driver cleanup function hooks into ppc_md.machine_crash_shutdown
> > and frees all firmware resources at shutdown time of the crashed
kernel.
>
> This means the crashed kernel now has to be trusted to shut down and
> free up the resources.  Isn't trusting the crashing kernel in this way
> against the whole kdump idea?

I would hope that if the cleanup routine only does hcalls
and does not change any kernel memory areas, then the risk to damage
anything
else  in kernel should be pretty small. This should allow to catch most
cases,
but as always you can imagine situations where the kernel memory is broken
beyond hope to even restart the kdump kernel.


>
> > crash_kexec continues and loads new kernel.
> > The new kernel restarts the HEA driver within kdump kernel, which will
work
> > because resources have been freed before.
> >
> > Michael, would this work?

Is ppc_md.machine_crash_shutdown the right hook?

Gruss/Regards
Christoph R


