From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: [PATCH v12 06/13] seccomp: add system call filtering using BPF
Date: Thu, 01 Mar 2012 22:55:30 -0800
Message-ID: <4F506EE2.1050705@zytor.com>
References: <1330559620-23543-1-git-send-email-wad@chromium.org>    <1330559620-23543-6-git-send-email-wad@chromium.org>    <a6fdbe9d1daf6864589c9affc7048965.squirrel@webmail.greenhost.nl>    <4F50603B.7040505@zytor.com> <bc1b4ec8fbad5a5931a928f108a6095f.squirrel@webmail.greenhost.nl>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Will Drewry <wad@chromium.org>, linux-kernel@vger.kernel.org,
        linux-arch@vger.kernel.org, linux-doc@vger.kernel.org,
        kernel-hardening@lists.openwall.com, netdev@vger.kernel.org,
        x86@kernel.org, arnd@arndb.de, davem@davemloft.net, mingo@redhat.com,
        oleg@redhat.com, peterz@infradead.org, rdunlap@xenotime.net,
        mcgrathr@chromium.org, tglx@linutronix.de, luto@mit.edu,
        eparis@redhat.com, serge.hallyn@canonical.com, djm@mindrot.org,
        scarybeasts@gmail.com, pmoore@redhat.com, akpm@linux-foundation.org,
        corbet@lwn.net, eric.dumazet@gmail.com, markus@chromium.org,
        coreyb@linux.vnet.ibm.com, keescook@chromium.org
To: Indan Zupancic <indan@nul.nu>
Return-path: <kernel-hardening-return-1031-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <bc1b4ec8fbad5a5931a928f108a6095f.squirrel@webmail.greenhost.nl>
List-Id: netdev.vger.kernel.org

On 03/01/2012 10:43 PM, Indan Zupancic wrote:
> On Fri, March 2, 2012 06:52, H. Peter Anvin wrote:
>> On 03/01/2012 09:45 PM, Indan Zupancic wrote:
>>>
>>>> + * @nr: the system call number
>>>> + * @arch: indicates system call convention as an AUDIT_ARCH_* value
>>>> + *        as defined in <linux/audit.h>.
>>>> + * @instruction_pointer: at the time of the system call.
>>>
>>> If the vDSO is used this will always be the same, so what good is this?
>>> I haven't gotten an answer to this yet.
>>>
>>
>> And if it isn't, or you're on an architecture which doesn't use the vdso
>> as the launching point, it's not.
> 
> True, but then what?
> 

Ok, fail on my part - I misread the above to refer to @arch, not
@instruction_pointer.

>> -- Pin is a great example.
> Is that http://www.pintool.org/?
> 
> Can you explain how knowing the IP is useful for Pin?
> 
> All I am asking for is just one use case for providing the IP. Is that
> asking for too much?

However, it still applies.  For something like Pin, Pin may want to trap
on all or a subset from the instrumented program, while the
instrumentation code -- which lives in the same address space -- needs
to execute those same instructions.

Yes, it's useless for *security* (unless perhaps if you keep very strict
tabs on the flow of control by using debug registers, dynamic
translation or whatnot), but it can be highly useful for
*instrumentation*, where you want to analyze the behavior of a
non-malicious program.

	-hpa

-- 
H. Peter Anvin, Intel Open Source Technology Center
I work for Intel.  I don't speak on their behalf.
