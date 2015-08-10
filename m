From: Liberman Igal <Igal.Liberman@freescale.com>
Subject: RE: [v4, 0/9] Freescale DPAA FMan
Date: Mon, 10 Aug 2015 19:55:32 +0000
Message-ID: <DM2PR03MB509B94619368C3718BDD28AE6700@DM2PR03MB509.namprd03.prod.outlook.com>
References: <1438766725-8053-1-git-send-email-igal.liberman@freescale.com>
 <20150807.153102.533553009548852567.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Scott Wood <scottwood@freescale.com>,
	Madalin-Cristian Bucur <madalin.bucur@freescale.com>,
	"pebolle@tiscali.nl" <pebolle@tiscali.nl>,
	"joakim.tjernlund@transmode.se" <joakim.tjernlund@transmode.se>,
	"ppc@mindchasers.com" <ppc@mindchasers.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150807.153102.533553009548852567.davem@davemloft.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello David,

Thank you for your feedback.

I understand your concerns regarding the FMan driver, we've come a long way from where we started but still there are issues.
The community support is critical for getting the code to the desired quality level and I appreciate the support I receive from you and from the other previous reviewers.

In order to reduce the code scattering I plan to put together all the code for a certain IP block in one file.
For example FMan port in his current state in /drivers/net/freescale/fman/:
        flib (directory)
              ---- fsl_fman_port.h
        inc (directory)
              ---- fm_port_ext.h (API for other drivers/modules)
        port (directory)
              ---- fman_port.c (flib)
              ---- fm_port.c
              ---- fm_port.h
              ---- Makefile
        fm_port_drv.c (file)

New proposed structure in /drivers/net/freescale/fman/:
        fman_port_drv.c (includes simplified code from fm_port.c, fman_port.c and fm_port_drv.c)
        fman_port_drv.h (exported structures and API, minimal)

Of-course, I'll do the same for other modules (MAC, FMan itself).

After this structure change we get:
- Subdirectories completely removed
- Layering reduced, each module becomes much flatter, with one source and header file
- Fewer number of files (sources and headers)
- Namespace pollution drastically reduced
- General complexity of the driver reduced.

I would appreciate your comments about the steps described above.

Regards,
Igal

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Saturday, August 08, 2015 1:31 AM
> To: Liberman Igal-B31950 <Igal.Liberman@freescale.com>
> Cc: netdev@vger.kernel.org; linuxppc-dev@lists.ozlabs.org; linux-
> kernel@vger.kernel.org; Wood Scott-B07421 <scottwood@freescale.com>;
> Bucur Madalin-Cristian-B32716 <madalin.bucur@freescale.com>;
> pebolle@tiscali.nl; joakim.tjernlund@transmode.se; ppc@mindchasers.com;
> stephen@networkplumber.org
> Subject: Re: [v4, 0/9] Freescale DPAA FMan
> 
> From: <igal.liberman@freescale.com>
> Date: Wed, 5 Aug 2015 12:25:16 +0300
> 
> > The Freescale Data Path Acceleration Architecture (DPAA) is a set of
> > hardware components on specific QorIQ multicore processors.
> > This architecture provides the infrastructure to support simplified
> > sharing of networking interfaces and accelerators by multiple CPU
> > cores and the accelerators.
> 
> I think the directory and code structure of this new driver is quite excessive.
> 
> Because you've split things up _so_ much, you have to have all of these
> directories, and even worse and much more important to me you have to
> export so many functions from one source file to another.
> 
> I think this is way too much.
> 
> For example, in one file you have a bunch of initialization routines.
> init_a(), init_b(), init_c(), and you export them all.  Then they are always
> called in sequence:
> 
> 	init_a();
> 	init_b();
> 	init_c();
> 
> This is completely pointless.  You just needed to export one function which
> calls all three functions.
> 
> The namespace pollution of this driver is out of control.
> 
> You really need to completely rework the architecture and layout of this
> driver before I will even begin to review it again.
> 
> And the lack of review interest by other developers should be an indication
> to you how undesirable this code submission is to read.
> 
> Thanks.
