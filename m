From: Markus Gutschke <markus@chromium.org>
Subject: Re: [PATCH v10 07/11] signal, x86: add SIGSYS info and make it synchronous.
Date: Thu, 23 Feb 2012 14:33:02 -0800
Message-ID: <CAE6n16kusCN9LxwqB1D2Dsm50mtc-6zkRje69D=QDdxxzWFTKw@mail.gmail.com>
References: <1329845435-2313-1-git-send-email-wad@chromium.org>
 <1329845435-2313-7-git-send-email-wad@chromium.org> <9edbabb2262e3d91a7b8c75dbec03d7f.squirrel@webmail.greenhost.nl>
 <CABqD9hY1n9EOAKKT0r9Ev+azhBMnLMAM_FgDNe5we9upVePk_A@mail.gmail.com>
 <CAObL_7Gc0U2JMBQr_kbcVUJwyJq7LRfgdFr+84LR=ec4kSCwEA@mail.gmail.com>
 <CAGXu5jJQrnkCZtcLqK8NEihRgB25C12b0nKp+XWXV_=4QfcVoA@mail.gmail.com>
 <CABqD9hbC8v-rUBW+4T_-EwDwe1+VDohQZweQ-cxOg2A-iDH5CQ@mail.gmail.com>
 <CAGXu5j+fQqkrrKSm3kmCkCcZJKo-VZjL6kkrOD81LZYBY7tf2g@mail.gmail.com>
 <4F45887A.5010809@zytor.com> <CAB=4xhq1sm_ewZ_8Kerf2aN7nGx+DEENse7Lqg5N0wuvqtzUAw@mail.gmail.com>
 <4F459109.1060205@zytor.com> <CAB=4xhqndEw3tMPaUcdZh_jcjQcoK_=7GwOc5gVhnz5o_4eWzQ@mail.gmail.com>
 <CABqD9hbsZTtkFzM_8rHqAWjZhiV0iWb6s1eMF9LriH-NybrorA@mail.gmail.com> <fe2d4b97d84c1e8053c397a20eec7ac8.squirrel@webmail.greenhost.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Will Drewry <wad@chromium.org>,
	Roland McGrath <mcgrathr@google.com>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Kees Cook <keescook@chromium.org>,
	Andrew Lutomirski <luto@mit.edu>, linux-kernel@vger.kernel.org,
	linux-arch@vger.kernel.org, linux-doc@vger.kernel.org,
	kernel-hardening@lists.openwall.com, netdev@vger.kernel.org,
	x86@kernel.org, arnd@arndb.de, davem@davemloft.net,
	mingo@redhat.com, oleg@redhat.com, peterz@infradead.org,
	rdunlap@xenotime.net, tglx@linutronix.de, eparis@redhat.com,
	serge.hallyn@canonical.com, djm@mindrot.org, scarybeasts@gmail.com,
	pmoore@redhat.com, akpm@linux-foundation.org, corbet@lwn.net,
	eric.dumazet@gmail.com
To: Indan Zupancic <indan@nul.nu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:35570 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755810Ab2BWWdY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Feb 2012 17:33:24 -0500
Received: by daed14 with SMTP id d14so1755287dae.19
        for <netdev@vger.kernel.org>; Thu, 23 Feb 2012 14:33:23 -0800 (PST)
In-Reply-To: <fe2d4b97d84c1e8053c397a20eec7ac8.squirrel@webmail.greenhost.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 23, 2012 at 14:15, Indan Zupancic <indan@nul.nu> wrote:
> What about making SECCOMP_RET_TRAP dump core/send SIGSYS if there is
> no tracer with PTRACE_O_SECCOMP set?

Please don't make things dependent on having a tracer. There are
applications that don't really need a tracer; in fact, these are
typically the exact same applications that can benefit from receiving
SIGSYS and then handling it internally.

If a tracer was required to set this up, it would make it difficult to
use gdb, strace, or any other common debugging tools.

> Sending SIGSYS is useful, but it's quite a bit less useful if user
> space can't handle it in a signal handler, so I don't think it's
> worth it to make a unblockable version.

Maybe, I am not parsing your e-mail correctly. But don't we already
get the desired behavior, if SIGSYS is treated the same as any other
synchronous signal? If it is unblocked and has a handler, the
application can decide to handle it. If neither one of these
conditions is true, it terminates the program. Ulimits and
PR_SET_DUMPABLE determine whether a core file is generated.


Markus
