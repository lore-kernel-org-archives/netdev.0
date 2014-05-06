From: Andi Kleen <andi@firstfloor.org>
Subject: Re: RFC: A reduced Linux network stack for small systems
Date: Tue, 6 May 2014 22:00:47 +0200
Message-ID: <20140506200047.GB5619@two.firstfloor.org>
References: <1399328773-6531-1-git-send-email-andi@firstfloor.org>
 <CAFLxGvww8t-PpuS3B=dFvn8k3xBydk3CgA=qoLyEbkKJZJ0xhQ@mail.gmail.com>
 <1399383246.8767.99.camel@empanada>
 <CAADnVQLYiNfXRrXc=VZkGEFDbNhF63AzPg6Gyu6P1SF=6AiO7g@mail.gmail.com>
 <1399390490.8767.122.camel@empanada>
 <CAADnVQ+nCtshedoDWN+QgiKzsCzBcojZOzrhkfzsqyXTpi4L=w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tom Zanussi <tom.zanussi@linux.intel.com>,
	Richard Weinberger <richard.weinberger@gmail.com>,
	Andi Kleen <andi@firstfloor.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAADnVQ+nCtshedoDWN+QgiKzsCzBcojZOzrhkfzsqyXTpi4L=w@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> not quite. I'm saying: no extra optimizations, no GCC changes.
> Compile kernel as-is. Most functions have a stub for mcount() already.
> Use it to track whether kernel function was called or not.
> Collect this data in userspace (as perf already does), add few
> more functions that had 'notrace' attribute on them, and feed this into
> special linker that unpacks existing vmlinux, throws away cold functions,
> relocates the rest and here you have tiny vmlinux without recompilation.

That's very difficult for networking code. How would you know you 
exercised all the corner cases in the TCP stack? And you wouldn't
want a remotely exploitable system because some important error
handler is missing.

I agree it may work for some other subsystems.

-Andi
