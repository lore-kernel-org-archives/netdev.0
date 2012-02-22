From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: [PATCH v10 05/11] seccomp: add system call filtering using BPF
Date: Wed, 22 Feb 2012 11:53:42 -0800
Message-ID: <4F4547C6.8050001@zytor.com>
References: <1329845435-2313-1-git-send-email-wad@chromium.org> <1329845435-2313-5-git-send-email-wad@chromium.org> <38d58caa17befe422065efe5dc451a34.squirrel@webmail.greenhost.nl> <CABqD9hYTLNrQKzYiRV6yN-z_mYyfPR=3W1P6nC+VmYmFGE1vQg@mail.gmail.com>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Indan Zupancic <indan@nul.nu>, linux-kernel@vger.kernel.org,
        linux-arch@vger.kernel.org, linux-doc@vger.kernel.org,
        kernel-hardening@lists.openwall.com, netdev@vger.kernel.org,
        x86@kernel.org, arnd@arndb.de, davem@davemloft.net, mingo@redhat.com,
        oleg@redhat.com, peterz@infradead.org, rdunlap@xenotime.net,
        mcgrathr@chromium.org, tglx@linutronix.de, luto@mit.edu,
        eparis@redhat.com, serge.hallyn@canonical.com, djm@mindrot.org,
        scarybeasts@gmail.com, pmoore@redhat.com, akpm@linux-foundation.org,
        corbet@lwn.net, eric.dumazet@gmail.com, markus@chromium.org,
        keescook@chromium.org
To: Will Drewry <wad@chromium.org>
Return-path: <kernel-hardening-return-914-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <CABqD9hYTLNrQKzYiRV6yN-z_mYyfPR=3W1P6nC+VmYmFGE1vQg@mail.gmail.com>
List-Id: netdev.vger.kernel.org

On 02/22/2012 11:47 AM, Will Drewry wrote:
>>
>> I highly disagree with every filter having to check the mode: Filters that
>> don't check the arch on e.g. x86 are buggy, so they have to check it, even
>> if it's a 32-bit or 64-bit only system, the filters can't know that and
>> needs to check the arch at every syscall entry. All other info in the data
>> depends on the arch, because of this there isn't much code to share between
>> the two archs, so you can as well have one filter for each arch.
>>
>> Alternative approach: Tell the arch at filter install time and only run the
>> filters with the same arch as the current system call. If no filters are run,
>> deny the systemcall.
> 
> This was roughly how I first implemented compat and non-compat
> support.  It causes some implicit behavior across inheritance that is
> not nice though.
> 

This is trivially doable at the BPF level, right?  Just make this the
first instruction in the program (either deny or jump to a separate
program branch)... and then there is still "one program" without any
weird inheritance issues?

	-hpa

-- 
H. Peter Anvin, Intel Open Source Technology Center
I work for Intel.  I don't speak on their behalf.
