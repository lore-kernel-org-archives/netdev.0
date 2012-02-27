From: Roland McGrath <mcgrathr@google.com>
Subject: Re: [PATCH v11 08/12] signal, x86: add SIGSYS info and make it synchronous.
Date: Mon, 27 Feb 2012 09:34:19 -0800
Message-ID: <CAB=4xhpXB7K88sJXur5VK_-0BA0ZrSeT6UDQv3PS+FyjrSFsOw@mail.gmail.com>
References: <1330140111-17201-1-git-send-email-wad@chromium.org>
 <1330140111-17201-8-git-send-email-wad@chromium.org> <20120227172208.GC10608@redhat.com>
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
	coreyb@linux.vnet.ibm.com, keescook@chromium.org
To: Oleg Nesterov <oleg@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:58584 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753324Ab2B0Rem (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Feb 2012 12:34:42 -0500
Received: by qcqw6 with SMTP id w6so1118283qcq.19
        for <netdev@vger.kernel.org>; Mon, 27 Feb 2012 09:34:41 -0800 (PST)
In-Reply-To: <20120227172208.GC10608@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 27, 2012 at 9:22 AM, Oleg Nesterov <oleg@redhat.com> wrote:
> SYNCHRONOUS_MASK just tells dequeue_signal() "pick them first".
> This is needed to make sure that the handler for, say SIGSEGV,
> can use ucontext->ip as a faulting addr.

It's desireable to have these signals handled first just so that the thread
state that provoked the signal is not obscured by an unrelated asynchronous
signal having its handler setup done beforehand.
