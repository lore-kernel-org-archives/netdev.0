From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: Subject: [PATCH 1/2] x86: get back 15 vectors
Date: Mon, 04 Jan 2010 11:48:12 -0800
Message-ID: <4B4245FC.7070902@zytor.com>
References: <4B347AEE.6030705@kernel.org> <20091228094707.GH24690@elte.hu>	<4B398ECD.1080506@kernel.org>	<4807377b1001031906s6b1ee576jc021da2642bb4147@mail.gmail.com>	<4B415E73.1050801@kernel.org> <4B419113.1090204@kernel.org>	<m1aawtlu6y.fsf@fess.ebiederm.org> <4B423B08.3010005@zytor.com> <m1my0thelq.fsf@fess.ebiederm.org> <4B424305.7050803@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Jesse Brandeburg <jesse.brandeburg@gmail.com>,
	Ingo Molnar <mingo@elte.hu>,
	Thomas Gleixner <tglx@linutronix.de>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	NetDEV list <netdev@vger.kernel.org>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Suresh Siddha <suresh.b.siddha@intel.com>
To: Yinghai Lu <yinghai@kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752774Ab0ADTtc@vger.kernel.org>
In-Reply-To: <4B424305.7050803@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[Adding Suresh to the Cc: list]

On 01/04/2010 11:35 AM, Yinghai Lu wrote:
> 
> so we can use [0x10, 0x1f]
> 
> sth like this?
> 

No!!!

[0x10, 0x1f] is reserved for exceptions.  We can probably get away with
stealing *one* vector... presumably at the end (0x1f).  However, we can
absolutely not use the whole block: 0x10-0x13 is occupied by exceptions
we already have OS support for (#MF, #AC, #MC, and #XM), and it's pretty
much guaranteed we'll have more coming.  However, growth is quite slow
and since this is a kernel-internal vector (not accessible to user
space) it is not creating an API.

In other words, we could change FIRST_EXTERNAL_VECTOR to 0x1f, and use
it for IRQ_MOVE_CLEANUP_VECTOR.  Then use 0x20..0x2f for the legacy vectors.

	-hpa
