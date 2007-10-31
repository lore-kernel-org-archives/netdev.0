From: Christoph Raisch <RAISCH@de.ibm.com>
Subject: Re: [PATCH] ehea: add kexec support
Date: Wed, 31 Oct 2007 20:48:28 +0100
Message-ID: <OF59B5FFD2.0294206F-ONC1257385.006A802D-C1257385.006CB6BB@de.ibm.com>
References: <200710261437.29117.ossthema@de.ibm.com>	 <1193610737.9637.1.camel@concordia>
	 <OF79E7ACE7.5D0488CE-ONC1257384.002E58C0-C1257384.002F8561@de.ibm.com> <1193784636.32504.4.camel@concordia>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Jan-Bernd Themann <THEMANN@de.ibm.com>,
	Jeff Garzik <jeff@garzik.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	Marcus Eder <MEDER@de.ibm.com>,
	netdev <netdev@vger.kernel.org>, ossthema@linux.vnet.ibm.com,
	Stefan Roscher <stefan.roscher@de.ibm.com>,
	Thomas Q Klein <TKLEIN@de.ibm.com>
To: michael@ellerman.id.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate8.de.ibm.com ([195.212.29.157]:40945 "EHLO
	mtagate8.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752204AbXJaTr3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Oct 2007 15:47:29 -0400
In-Reply-To: <1193784636.32504.4.camel@concordia>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Michael Ellerman <michael@ellerman.id.au> wrote on 30.10.2007 23:50:36:
>
> On Tue, 2007-10-30 at 09:39 +0100, Christoph Raisch wrote:
> >
> > Michael Ellerman <michael@ellerman.id.au> wrote on 28.10.2007 23:32:17:
> > Hope I didn't miss anything here...
>
> Perhaps. When we kdump the kernel does not call the reboot notifiers, so
> the code Jan-Bernd just added won't get called. So the eHEA resources
> won't be freed. When the kdump kernel tries to load the eHEA driver what
> will happen?
>
Good point.

If the device driver tries to allocate resources again (in the kdump
kernel),
which have been allocated before (in the crashed kernel) the hcalls will
fail because from the hypervisor view the resources are still in use.
Currently there's no method to find out the resource handles for these
HEA resources allocated by the crashed kernel within the hypervisor...

So we have to trigger a explicit deregister in the hypervisor before the
driver
is started again.
How do you recommend we should trigger this in the kdump process?
Is placing a hook into a ppc_md.machine_kexec be an option?

Gruss / Regards
Christoph R.

