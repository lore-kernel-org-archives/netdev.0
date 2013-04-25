From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: [PATCH] x86: make DR*_RESERVED unsigned long
Date: Wed, 24 Apr 2013 18:20:33 -0700
Message-ID: <517884E1.5060404@zytor.com>
References: <CA+55aFwpLu0qNms=hkQr43yqD0K9DgESNm91OEWKT1ZuT8MU6Q@mail.gmail.com> <20130424072630.GB1780@gmail.com> <20130424170702.GA1867@redhat.com> <CAFTL4hzmW43o8dxW0_E7F00a+PT+T4=F4h=gdCxHvcZhMiH3-w@mail.gmail.com> <5178657E.9020905@zytor.com> <CAFTL4hyCQ1DGg5JOmWgvZoC9kcrV6TmodCw=TCFcr+QXMwv9yQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Cyrill Gorcunov <gorcunov@gmail.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Thomas Gleixner <tglx@linutronix.de>,
	David Miller <davem@davemloft.net>,
	"Theodore Ts'o" <tytso@mit.edu>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	the arch/x86 maintainers <x86@kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	"linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>
To: Frederic Weisbecker <fweisbec@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAFTL4hyCQ1DGg5JOmWgvZoC9kcrV6TmodCw=TCFcr+QXMwv9yQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/24/2013 04:31 PM, Frederic Weisbecker wrote:
>>
>> Now, DR6 is a bit special in that a bunch of the reserved bits are
>> hardwired to 1, not 0; I don't know offhand if that is true for bits
>> [63:32].
> 
> Hmm, good point, could it be a problem given that we clear the
> reserved dr6 bits on do_trap() and write that 'cleaned up" value back
> to "tsk->thread.debugreg6"? Probably not if those hardwired reserved
> bits are set to "1" on dr6 physical write whether those bits are
> cleared or not in their storage in thread struct before resuming the
> task?
> 

OK, the SDM states that DR6[63:32] are reserved and must be written as
zero (not one).

So the quiescent 64-bit value of DR6 is 0x0000_0000_FFFF_0FF0.

	-hpa
