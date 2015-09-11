From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH] x86: Wire up 32-bit direct socket calls
Date: Fri, 11 Sep 2015 11:54:50 +0200
Message-ID: <CAMuHMdXX31xZ4AS6FbeXLXgDn5UV5=0C3hrihuwDOP_abuJsBg@mail.gmail.com>
References: <cb5138299d37d5800e2d135b01a7667fa6115854.1436912629.git.luto@kernel.org>
	<3193269.4TGcgnGPrm@wuerfel>
	<20150911082429.GA12452@osiris>
	<49726621.LPTnfQXYGz@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>, "H. Peter Anvin" <hpa@zytor.com>,
	Andy Lutomirski <luto@kernel.org>, X86 ML <x86@kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Tulio Magno Quites Machado Filho <tuliom@linux.vnet.ibm.com>, Andy Lutomirski <luto@amacapital.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Alexander Larsson <alexl@redhat.com>,
	Cosimo Cecchi <cosimo@endlessm.com>, Dan Nicholson <nicholson@endlessm.com>,
	libc-alpha <libc-alpha@sourceware.org>,
	Rajalakshmi Srinivasaraghavan <raji@linux.vnet.ibm.com>, Linux-Arch <linux-arch@vger.kernel.org>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <libc-alpha-return-63122-glibc-alpha=m.gmane.org@sourceware.org>
List-Unsubscribe: <mailto:libc-alpha-unsubscribe-glibc-alpha=m.gmane.org@sourceware.org>
List-Subscribe: <mailto:libc-alpha-subscribe@sourceware.org>
List-Archive: <http://sourceware.org/ml/libc-alpha/>
List-Post: <mailto:libc-alpha@sourceware.org>
List-Help: <mailto:libc-alpha-help@sourceware.org>, <http://sourceware.org/ml/#faqs>
Sender: libc-alpha-owner@sourceware.org
In-Reply-To: <49726621.LPTnfQXYGz@wuerfel>
List-Id: netdev.vger.kernel.org

On Fri, Sep 11, 2015 at 10:46 AM, Arnd Bergmann <arnd@arndb.de> wrote:
> On Friday 11 September 2015 10:24:29 Heiko Carstens wrote:
>>
>> FWIW, the s390 approach (ignoring the "new" system calls) is only temporarily.
>> I'll enable the seperate calls later when I have time to test everything,
>> especially the glibc stuff.
>
> Ok, thanks for clarifying.
>
>> The same is true for the ipc system call. (any reason why the seperate system
>> calls haven't been enabled on x86 now as well?)
>
> Agreed, we should split that out on all architectures as well.
> Almost the same set of architectures that have sys_socketcall also
> have sys_ipc, and the reasons for changing are identical. I don't
> think we have any other system calls that are handled like this
> on some architectures but not on others. There are a couple of
> system calls (e.g. futex) that are also multiplexers, but at
> least they do it consistently.

To make sure I don't miss any (it seems I missed recvmmsg and sendmmsg for
the socketcall case, sigh), this is the list of ipc syscalls to implement?

    sys_msgget
    sys_msgctl
    sys_msgrcv
    sys_msgsnd
    sys_semget
    sys_semctl
    sys_semtimedop
    sys_shmget
    sys_shmctl
    sys_shmat
    sys_shmdt

sys_semop() seems to be unneeded because it can be implemented using
sys_semtimedop()?

Thanks!

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
