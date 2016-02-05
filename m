From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH v3 net-next] net: Implement fast csum_partial for x86_64
Date: Fri, 5 Feb 2016 09:01:36 +0100
Message-ID: <20160205080136.GA31671@gmail.com>
References: <1454527121-4007853-1-git-send-email-tom@herbertland.com>
 <20160204093021.GB1553@gmail.com>
 <CA+55aFxqs+mE=s4UkNQXJA8JjAKKb6vk1JO672jdEuWtsJ=hVg@mail.gmail.com>
 <CALx6S37+F9UnyDuOgXHKqhNQvBXoQe8G2GCWPbhZE8QBdmz3vg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, Peter Anvin <hpa@zytor.com>,
	the arch/x86 maintainers <x86@kernel.org>,
	kernel-team <kernel-team@fb.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>
To: Tom Herbert <tom@herbertland.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CALx6S37+F9UnyDuOgXHKqhNQvBXoQe8G2GCWPbhZE8QBdmz3vg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Tom Herbert <tom@herbertland.com> wrote:

> [....] gcc turns these switch statements into jump tables (not function tables 
> which is what Ingo's example code was using). [...]

So to the extent this still matters, on most x86 microarchitectures that count, 
jump tables and function call tables (i.e. virtual functions that C++ uses) are 
generally optimized by the same branch predictor hardware mechanism. Indirect 
jumps (jump tables) and indirect calls (function pointer tables) are very similar 
conceptually. That is why posted the indirect calls test code.

( The only branching variant that will perform badly even on the latest uarchs are
  indirect returns: to modify the return address on the stack. )

So my narrow performance point stands, if any sort of indirect jump is used. They 
should be avoided if possible, because it's pretty hard for the hardware to get it 
right.

As Linus noticed, data lookup tables are the intelligent solution: if you manage 
to offload the logic into arithmetics and not affect the control flow then that's 
a big win. The inherent branching will be hidden by executing on massively 
parallel arithmetics units which effectively execute everything fed to them in a 
single cycle.

In any case, when submitting such patches, please get into the habit of looking at 
and posting perf stat output - it will give us a good idea about the quality of an 
implementation.

Thanks,

	Ingo
