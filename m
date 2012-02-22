From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v10 05/11] seccomp: add system call filtering using BPF
Date: Wed, 22 Feb 2012 14:23:46 +0000
Message-ID: <1329920626.3258.174.camel@deadeye>
References: <1329845435-2313-1-git-send-email-wad@chromium.org>
	 <1329845435-2313-5-git-send-email-wad@chromium.org>
	 <38d58caa17befe422065efe5dc451a34.squirrel@webmail.greenhost.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Will Drewry <wad@chromium.org>, <linux-kernel@vger.kernel.org>,
	<linux-arch@vger.kernel.org>, <linux-doc@vger.kernel.org>,
	<kernel-hardening@lists.openwall.com>, <netdev@vger.kernel.org>,
	<x86@kernel.org>, <arnd@arndb.de>, <davem@davemloft.net>,
	<hpa@zytor.com>, <mingo@redhat.com>, <oleg@redhat.com>,
	<peterz@infradead.org>, <rdunlap@xenotime.net>,
	<mcgrathr@chromium.org>, <tglx@linutronix.de>, <luto@mit.edu>,
	<eparis@redhat.com>, <serge.hallyn@canonical.com>,
	<djm@mindrot.org>, <scarybeasts@gmail.com>, <pmoore@redhat.com>,
	<akpm@linux-foundation.org>, <corbet@lwn.net>,
	<eric.dumazet@gmail.com>, <markus@chromium.org>,
	<keescook@chromium.org>
To: Indan Zupancic <indan@nul.nu>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <38d58caa17befe422065efe5dc451a34.squirrel@webmail.greenhost.nl>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2012-02-22 at 09:19 +0100, Indan Zupancic wrote:
[...]
> Alternative approach: Tell the arch at filter install time and only run the
> filters with the same arch as the current system call. If no filters are run,
> deny the systemcall.
>
> Advantages:
> 
> - Filters don't have to check the arch every syscall entry.
> 
> - Secure by default. Filters don't have to do anything arch specific to
>   be secure, no surprises possible.
> 
> - If a new arch comes into existence, there is no chance of old filters
>   becoming buggy and insecure. This is especially true for archs that
>   had only one mode, but added another one later on: Old filters had no
>   need to check the mode at all.
[...]

What about when there are multiple layers of restrictions?  So long as
any one layer covers the new architecture, there is no default-deny even
though the other layers might not cover it.

I would have thought the way to make sure the architecture is always
checked is to pack it together with the syscall number.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
