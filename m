From: "Luck, Tony" <tony.luck@intel.com>
Subject: RE: [2/2] 2.6.23-rc2: known regressions with patches
Date: Mon, 6 Aug 2007 11:45:29 -0700
Message-ID: <617E1C2C70743745A92448908E030B2A0218E076@scsmsx411.amr.corp.intel.com>
References: <1186331976.3858.39.camel@fanta4.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Linus Torvalds" <torvalds@linux-foundation.org>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	"LKML" <linux-kernel@vger.kernel.org>,
	"Christoph Lameter" <clameter@sgi.com>,
	"Pekka Enberg" <penberg@cs.helsinki.fi>,
	"Peter Zijlstra" <peterz@infradead.org>,
	"Ingo Molnar" <mingo@elte.hu>, "Jan Dittmer" <jdi@l4x.org>,
	"Netdev" <netdev@vger.kernel.org>,
	"Joachim Deguara" <joachim.deguara@amd.com>,
	"Michael Chan" <mchan@broadcom.com>, <linux-scsi@vger.kernel.org>,
	"James Bottomley" <James.Bottomley@steeleye.com>,
	"Matthew Wilcox" <matthew@wil.cx>,
	"Seokmann Ju" <seokmann.ju@qlogic.com>,
	"Richard Lary" <rlary@us.ibm.com>
To: <trenn@suse.de>,
	"Michal Piotrowski" <michal.k.k.piotrowski@gmail.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <1186331976.3858.39.camel@fanta4.site>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > Caused-By       : Thomas Renninger <trenn@suse.de>
> >                   commit 29b71a1ca74491fab9fed09e9d835d840d042690

> A patch was sent to Tony. AFAIK it got accepted, not sure whether it
> already is in any and which git tree...

The suggested patch adds manual padding to the acpi_device_id structure
definition in include/linux/mod_devicetable.h  I didn't take it, and it
appears that nobody else did either.  It is not in Linus' tree (as of 2.6.23-rc2).

I expressed doubts about whether this is the right fix.  The problem
is that when cross-compiling a locally compiled utility makes a size &
alignment check.  This is bogus.  We shouldn't care whether this structure
compiles to the same size/alignment as the kernel that will use on the
target platform.

Is fixing this the right way (make the scripts/mod/file2alias.c understand
target alignment rules in a cross environment) just too hideous to
contemplate ... and we should just sacrifice 7 bytes of padding in
order to keep life simple?

-Tony
