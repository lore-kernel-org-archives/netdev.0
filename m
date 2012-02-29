From: Roland McGrath <mcgrathr@google.com>
Subject: Re: [PATCH v11 10/12] ptrace,seccomp: Add PTRACE_SECCOMP support
Date: Wed, 29 Feb 2012 09:41:13 -0800
Message-ID: <CAB=4xhq1CPz74LchQ32oyhR1vUKjhMiTXENYbgeh=BoaYNP9JQ@mail.gmail.com>
References: <1330140111-17201-1-git-send-email-wad@chromium.org>
 <1330140111-17201-10-git-send-email-wad@chromium.org> <20120227175407.GD10608@redhat.com>
 <CABqD9hY1P7LfmBwQwSG7jDZmw6d_pZH4q2cZq_4ssjQUKRA32w@mail.gmail.com>
 <20120228164335.GC3664@redhat.com> <CABqD9hY7=DpxWzf3+WNsK=LuLrabf=oHxyy+CQgu0JLxZ80zPQ@mail.gmail.com>
 <CABqD9hZ3apFGi+BmX5UNgz=NJUbTigj6acDKG=wu9rrL0wN1Ww@mail.gmail.com>
 <20120229161437.GA3078@redhat.com> <CABqD9hZLi416irXMMPmysYohrOn1gQjhjDyKTggU80Kd7ywvcA@mail.gmail.com>
 <20120229170933.GA6149@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Will Drewry <wad@chromium.org>, linux-kernel@vger.kernel.org,
	linux-arch@vger.kernel.org, linux-doc@vger.kernel.org,
	kernel-hardening@lists.openwall.com, netdev@vger.kernel.org,
	x86@kernel.org, arnd@arndb.de, davem@davemloft.net, hpa@zytor.com,
	mingo@redhat.com, peterz@infradead.org, rdunlap@xenotime.net,
	tglx@linutronix.de, luto@mit.edu, eparis@redhat.com,
	serge.hallyn@canonical.com, djm@mindrot.org, scarybeasts@gmail.com,
	indan@nul.nu, pmoore@redhat.com, akpm@linux-foundation.org,
	corbet@lwn.net, eric.dumazet@gmail.com, markus@chromium.org,
	coreyb@linux.vnet.ibm.com, keescook@chromium.org,
	Denys Vlasenko <dvlasenk@redhat.com>
To: Oleg Nesterov <oleg@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:42786 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755797Ab2B2Rle (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Feb 2012 12:41:34 -0500
Received: by iagz16 with SMTP id z16so5063iag.19
        for <netdev@vger.kernel.org>; Wed, 29 Feb 2012 09:41:34 -0800 (PST)
In-Reply-To: <20120229170933.GA6149@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I don't think TIF_NOTIFY_RESUME is apropos here.  That only triggers on
returning to user mode, i.e. after syscall exit.  But regardless of the
exact implementation details, I don't think it will be prohibitive to add
some means by which the fast-path can back off before actual syscall entry
and go to the slow path for ptrace reporting.

Since there is no strong reason to think it can't be reorganized that way
later, I don't see any good rationale for constraining the seccomp-filter
feature definition based on a plan to optimize the implementation in the
future.


Thanks,
Roland
