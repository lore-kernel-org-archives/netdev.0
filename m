From: Frederic Weisbecker <fweisbec@gmail.com>
Subject: Re: [PATCH] x86: make DR*_RESERVED unsigned long
Date: Thu, 25 Apr 2013 00:48:57 +0200
Message-ID: <CAFTL4hzmW43o8dxW0_E7F00a+PT+T4=F4h=gdCxHvcZhMiH3-w@mail.gmail.com>
References: <CA+55aFwpLu0qNms=hkQr43yqD0K9DgESNm91OEWKT1ZuT8MU6Q@mail.gmail.com>
	<20130424072630.GB1780@gmail.com>
	<20130424170702.GA1867@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Cyrill Gorcunov <gorcunov@gmail.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	David Miller <davem@davemloft.net>,
	"Theodore Ts'o" <tytso@mit.edu>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"the arch/x86 maintainers" <x86@kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	"linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>
To: Oleg Nesterov <oleg@redhat.com>
Return-path: <linux-ext4-owner@vger.kernel.org>
In-Reply-To: <20130424170702.GA1867@redhat.com>
Sender: linux-ext4-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2013/4/24 Oleg Nesterov <oleg@redhat.com>:
> DR6_RESERVED and DR_CONTROL_RESERVED are used to clear the set
> bits in the "unsigned long" data, make them long to ensure that
> "&~" doesn't clear the upper bits.
>
> do_debug() and ptrace_write_dr7() which use DR*_RESERVED look
> safe, but probably it makes sense to cleanup anyway.

Agreed. The code looks safe, but the pattern is error prone. I'm all
for that cleanup.
Just something below:

>
> Reported-by: Linus Torvalds <torvalds@linux-foundation.org>
> Signed-off-by: Oleg Nesterov <oleg@redhat.com>
> ---
>  arch/x86/include/uapi/asm/debugreg.h |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/arch/x86/include/uapi/asm/debugreg.h b/arch/x86/include/uapi/asm/debugreg.h
> index 3c0874d..75d07dd 100644
> --- a/arch/x86/include/uapi/asm/debugreg.h
> +++ b/arch/x86/include/uapi/asm/debugreg.h
> @@ -15,7 +15,7 @@
>     are either reserved or not of interest to us. */
>
>  /* Define reserved bits in DR6 which are always set to 1 */
> -#define DR6_RESERVED   (0xFFFF0FF0)
> +#define DR6_RESERVED   (0xFFFF0FF0ul)

You told in an earlier email that intel manual says upper 32 bits of
dr6 are reserved.
In this case don't we need to expand the mask in 64 bits like is done
for DR_CONTROL_RESERVED?

Thanks.
