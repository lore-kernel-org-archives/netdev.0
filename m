From: Roland McGrath <mcgrathr@google.com>
Subject: Re: [PATCH v10 07/11] signal, x86: add SIGSYS info and make it synchronous.
Date: Wed, 22 Feb 2012 16:11:01 -0800
Message-ID: <CAB=4xhpgfrgEf7BhYUu5BYR1QrzBZk_nLk43UDAZ9uXC4dJGwA@mail.gmail.com>
References: <1329845435-2313-1-git-send-email-wad@chromium.org>
 <1329845435-2313-7-git-send-email-wad@chromium.org> <9edbabb2262e3d91a7b8c75dbec03d7f.squirrel@webmail.greenhost.nl>
 <CABqD9hY1n9EOAKKT0r9Ev+azhBMnLMAM_FgDNe5we9upVePk_A@mail.gmail.com> <CAObL_7Gc0U2JMBQr_kbcVUJwyJq7LRfgdFr+84LR=ec4kSCwEA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Will Drewry <wad@chromium.org>, Indan Zupancic <indan@nul.nu>,
	linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-doc@vger.kernel.org, kernel-hardening@lists.openwall.com,
	netdev@vger.kernel.org, x86@kernel.org, arnd@arndb.de,
	davem@davemloft.net, hpa@zytor.com, mingo@redhat.com,
	oleg@redhat.com, peterz@infradead.org, rdunlap@xenotime.net,
	tglx@linutronix.de, eparis@redhat.com, serge.hallyn@canonical.com,
	djm@mindrot.org, scarybeasts@gmail.com, pmoore@redhat.com,
	akpm@linux-foundation.org, corbet@lwn.net, eric.dumazet@gmail.com,
	markus@chromium.org, keescook@chromium.org
To: Andrew Lutomirski <luto@mit.edu>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <CAObL_7Gc0U2JMBQr_kbcVUJwyJq7LRfgdFr+84LR=ec4kSCwEA@mail.gmail.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 22, 2012 at 3:38 PM, Andrew Lutomirski <luto@mit.edu> wrote=
:
> I wonder if it would be helpful to change the semantics of RET_KILL
> slightly. =A0Rather than killing via do_exit, what if it killed via a
> forcibly-fatal SIGSYS? =A0That way, the parent's waitid() / SIGCHLD
> would indicate CLD_KILLED with si_status =3D=3D SIGSYS. =A0The parent=
 could
> check that and report that the child was probably compromised.

That would be better.  But it is certainly a more complex code path, wh=
ich
makes the security weenies twitch.  As to concrete issues, any "normal"
path needs the changes that are maybe pending from Oleg to make it actu=
ally
abort the syscall instead of completing it before getting to the signal=
 path.
