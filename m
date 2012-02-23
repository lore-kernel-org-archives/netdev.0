From: Will Drewry <wad@chromium.org>
Subject: Re: [PATCH v10 07/11] signal, x86: add SIGSYS info and make it synchronous.
Date: Thu, 23 Feb 2012 10:44:29 -0600
Message-ID: <CABqD9havUbeHDQVqxf7iy1XjNSrUkh=ehSW_h2OfU2QQ_VQaaA@mail.gmail.com>
References: <1329845435-2313-1-git-send-email-wad@chromium.org>
	<1329845435-2313-7-git-send-email-wad@chromium.org>
	<9edbabb2262e3d91a7b8c75dbec03d7f.squirrel@webmail.greenhost.nl>
	<CABqD9hY1n9EOAKKT0r9Ev+azhBMnLMAM_FgDNe5we9upVePk_A@mail.gmail.com>
	<CAObL_7Gc0U2JMBQr_kbcVUJwyJq7LRfgdFr+84LR=ec4kSCwEA@mail.gmail.com>
	<CAGXu5jJQrnkCZtcLqK8NEihRgB25C12b0nKp+XWXV_=4QfcVoA@mail.gmail.com>
	<CABqD9hbC8v-rUBW+4T_-EwDwe1+VDohQZweQ-cxOg2A-iDH5CQ@mail.gmail.com>
	<CAGXu5j+fQqkrrKSm3kmCkCcZJKo-VZjL6kkrOD81LZYBY7tf2g@mail.gmail.com>
	<4F45887A.5010809@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Kees Cook <keescook@chromium.org>,
	Andrew Lutomirski <luto@mit.edu>,
	Indan Zupancic <indan@nul.nu>, linux-kernel@vger.kernel.org,
	linux-arch@vger.kernel.org, linux-doc@vger.kernel.org,
	kernel-hardening@lists.openwall.com, netdev@vger.kernel.org,
	x86@kernel.org, arnd@arndb.de, davem@davemloft.net,
	mingo@redhat.com, oleg@redhat.com, peterz@infradead.org,
	rdunlap@xenotime.net, mcgrathr@chromium.org, tglx@linutronix.de,
	eparis@redhat.com, serge.hallyn@canonical.com, djm@mindrot.org,
	scarybeasts@gmail.com, pmoore@redhat.com,
	akpm@linux-foundation.org, corbet@lwn.net, eric.dumazet@gmail.com,
	markus@chromium.org
To: "H. Peter Anvin" <hpa@zytor.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <4F45887A.5010809@zytor.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 22, 2012 at 6:29 PM, H. Peter Anvin <hpa@zytor.com> wrote:
> On 02/22/2012 04:08 PM, Kees Cook wrote:
>>>
>>> Hrm, it might be possible to do_exit(SIGSYS) which would be both. I=
t
>>> looks like tsk->exit_code would be SIGSYS then, but I'll look a lit=
tle
>>> more closely to see what that'll actually do.
>>
>> As long as there's no way it can get blocked, I'd be fine with that.
>> It would, actually, be better than SIGKILL because, as Andy said, it=
's
>> more distinguishable from other situations. I've long wanted a signa=
l
>> to be used for "violated policy" that wasn't just a straight SIGKILL=
=2E
>>
>
> Can we really introduce force-kill semantics for a POSIX-defined sign=
al?
> =A0Other user space programs might use it for other purposes.
>
> I'm wondering if the right thing may be to introduce some variant of
> exit() which can return more information about a signal, including so=
me
> kind of cause code for SIGKILL?

While it'd be harder to send back extra info, passing SIGSYS to
do_exit() should result in the si_status for the emitted SIGCHLD to be
SIGSYS (si_status =3D (tsk->exit_code & 0x7f)).  I think it'll still
have a si_code of CLD_KILLED, but it'd be enough for a parent to
differentiate the task-death path.  I'll try it out before I post
another patch rev.

A variant that allowed extended exit information would be useful
(especially for this patch series), I'm not sure I'd know where to
start.

cheers!
will
