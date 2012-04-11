From: Will Drewry <wad@chromium.org>
Subject: Re: [PATCH v15 04/13] arch/x86: add syscall_get_arch to syscall.h
Date: Tue, 10 Apr 2012 22:13:52 -0500
Message-ID: <CABqD9hZgnrKFY_Wei-ysU=Dy7Og2iEemnqPvcQ14M0+vL65gHQ@mail.gmail.com>
References: <1331781125-15658-1-git-send-email-wad@chromium.org>
	<1331781125-15658-5-git-send-email-wad@chromium.org>
	<4F6F7362.6030402@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-doc@vger.kernel.org, kernel-hardening@lists.openwall.com,
	netdev@vger.kernel.org, x86@kernel.org, arnd@arndb.de,
	davem@davemloft.net, mingo@redhat.com, oleg@redhat.com,
	peterz@infradead.org, rdunlap@xenotime.net, mcgrathr@chromium.org,
	tglx@linutronix.de, luto@mit.edu, eparis@redhat.com,
	serge.hallyn@canonical.com, djm@mindrot.org, scarybeasts@gmail.com,
	indan@nul.nu, pmoore@redhat.com, akpm@linux-foundation.org,
	corbet@lwn.net, eric.dumazet@gmail.com, markus@chromium.org,
	coreyb@linux.vnet.ibm.com, keescook@chromium.org
To: "H. Peter Anvin" <hpa@zytor.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <4F6F7362.6030402@zytor.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Mar 25, 2012 at 2:34 PM, H. Peter Anvin <hpa@zytor.com> wrote:
> On 03/14/2012 08:11 PM, Will Drewry wrote:
>>
>> +static inline int syscall_get_arch(struct task_struct *task,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0str=
uct pt_regs *regs)
>> +{
>> +#ifdef CONFIG_IA32_EMULATION
>> + =A0 =A0 /*
>> + =A0 =A0 =A0* TS_COMPAT is set for 32-bit syscall entries and then
>> + =A0 =A0 =A0* remains set until we return to user mode.
>> + =A0 =A0 =A0*
>> + =A0 =A0 =A0* TIF_IA32 tasks should always have TS_COMPAT set at
>> + =A0 =A0 =A0* system call time.
>> + =A0 =A0 =A0*/
>> + =A0 =A0 if (task_thread_info(task)->status & TS_COMPAT)
>> + =A0 =A0 =A0 =A0 =A0 =A0 return AUDIT_ARCH_I386;
>> +#endif
>> + =A0 =A0 return AUDIT_ARCH_X86_64;
>> +}
>> =A0#endif =A0 =A0 =A0 /* CONFIG_X86_32 */
>>
>> =A0#endif =A0 =A0 =A0 /* _ASM_X86_SYSCALL_H */
>
> Just one FYI on this: after the x32 changes are upstream this can be
> implemented in terms of is_ia32_task().

Now that I've seen is_ia32_task(), it appears to be exactly the same as=
 above:
(1)  If we're x86_32, it's ia32
(2)  If we're x86_64, ia32 =3D=3D !!(status & TS_COMPAT)
(3)  Otherwise, it's x86_64, including x32

Am I missing something? Should is_ia32_task(void) take a task_struct?
Right now, I don't see any reason to change the code, as posted, but
maybe I am mis-reading?

thanks!
will
