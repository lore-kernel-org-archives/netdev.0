From: Jesse Barnes <jbarnes@virtuousgeek.org>
Subject: Re: oops/warning report for the week of November 26, 2008
Date: Thu, 27 Nov 2008 09:02:12 -0800
Message-ID: <200811270902.18020.jbarnes@virtuousgeek.org>
References: <492DD792.6080302@linux.intel.com> <20081127115236.GE29013@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Arjan van de Ven <arjan@linux.intel.com>,
	Yinghai Lu <yinghai@kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	NetDev <netdev@vger.kernel.org>, x86@kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	"Theodore Ts'o" <tytso@mit.edu>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753056AbYK0RCc@vger.kernel.org>
In-Reply-To: <20081127115236.GE29013@elte.hu>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday, November 27, 2008 3:52 am Ingo Molnar wrote:
> * Arjan van de Ven <arjan@linux.intel.com> wrote:
> > Rank 8: mtrr_trim_uncached_memory (warning)
> > 	Reported 227 times (619 total reports)
> > 	There is a high number of machines where our MTRR checks
> > 	trigger. I suspect we are too picky in accepting the MTRR
> > 	configuration.
>
> the warning here means: "the BIOS messed up but we fixed it up for
> you just fine".
>
> Should we print a DMI descriptor so that it can be tracked back to the
> bad BIOSen in question? Or should we (partially) silence the warning
> itself? Those BIOS bugs need fixing really: older kernels will boot up
> with bad MTRR settings - resulting in a super-slow system or other
> weirdnesses. We can tone down the message so that it doesnt show up in
> kerneloops.org. It's up to you.

I actually think we're doing something wrong here, since so many platforms 
have this behavior.  It's likely that there's an undocumented, additional 
check needed to determine whether a slot is hot pluggable.  Matthew Garrett 
recently posted a patch to check for ACPI _RMV methods, which should be an 
improvement.  I'll be putting that into linux-next soon for testing.

-- 
Jesse Barnes, Intel Open Source Technology Center
