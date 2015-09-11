From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] x86: Wire up 32-bit direct socket calls
Date: Fri, 11 Sep 2015 12:14:13 +0200
Message-ID: <2108882.tTxglVCXxY@wuerfel>
References: <cb5138299d37d5800e2d135b01a7667fa6115854.1436912629.git.luto@kernel.org> <49726621.LPTnfQXYGz@wuerfel> <CAMuHMdXX31xZ4AS6FbeXLXgDn5UV5=0C3hrihuwDOP_abuJsBg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andy Lutomirski <luto@kernel.org>, X86 ML <x86@kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Tulio Magno Quites Machado Filho
	<tuliom@linux.vnet.ibm.com>, Andy Lutomirski <luto@amacapital.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Alexander Larsson <alexl@redhat.com>,
	Cosimo Cecchi <cosimo@endlessm.com>,
	Dan Nicholson <nicholson@endlessm.com>,
	libc-alpha <libc-alpha@sourceware.org>,
	Rajalakshmi Srinivasaraghavan <raji@linux.vnet.ibm.com>,
	Linux-Arch <linux-arch@vger.kernel.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <CAMuHMdXX31xZ4AS6FbeXLXgDn5UV5=0C3hrihuwDOP_abuJsBg@mail.gmail.com>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 11 September 2015 11:54:50 Geert Uytterhoeven wrote:
> To make sure I don't miss any (it seems I missed recvmmsg and sendmmsg for
> the socketcall case, sigh), this is the list of ipc syscalls to implement?
> 
>     sys_msgget
>     sys_msgctl
>     sys_msgrcv
>     sys_msgsnd
>     sys_semget
>     sys_semctl
>     sys_semtimedop
>     sys_shmget
>     sys_shmctl
>     sys_shmat
>     sys_shmdt
> 
> sys_semop() seems to be unneeded because it can be implemented using
> sys_semtimedop()?
> 

Yes, that list looks right. IPC also includes a set of six sys_mq_*
call, but I believe that everyone already has those as they are not
covered by sys_ipc.

For y2038 compatibility, we will likely add a new variant of
semtimedop that takes a 64-bit timespec. While the argument passed
there is a relative time that will never need to be longer than 68
years, we need to accommodate user space that defines timespec
in a sane way, and converting the argument in libc would be awkward.

	Arnd
