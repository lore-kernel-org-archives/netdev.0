From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: [PATCH v10 07/11] signal, x86: add SIGSYS info and make it synchronous.
Date: Wed, 22 Feb 2012 17:06:17 -0800
Message-ID: <4F459109.1060205@zytor.com>
References: <1329845435-2313-1-git-send-email-wad@chromium.org> <1329845435-2313-7-git-send-email-wad@chromium.org> <9edbabb2262e3d91a7b8c75dbec03d7f.squirrel@webmail.greenhost.nl> <CABqD9hY1n9EOAKKT0r9Ev+azhBMnLMAM_FgDNe5we9upVePk_A@mail.gmail.com> <CAObL_7Gc0U2JMBQr_kbcVUJwyJq7LRfgdFr+84LR=ec4kSCwEA@mail.gmail.com> <CAGXu5jJQrnkCZtcLqK8NEihRgB25C12b0nKp+XWXV_=4QfcVoA@mail.gmail.com> <CABqD9hbC8v-rUBW+4T_-EwDwe1+VDohQZweQ-cxOg2A-iDH5CQ@mail.gmail.com> <CAGXu5j+fQqkrrKSm3kmCkCcZJKo-VZjL6kkrOD81LZYBY7tf2g@mail.gmail.com> <4F45887A.5010809@zytor.com> <CAB=4xhq1sm_ewZ_8Kerf2aN7nGx+DEENse7Lqg5N0wuvqtzUAw@mail.gmail.com>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Kees Cook <keescook@chromium.org>, Will Drewry <wad@chromium.org>,
        Andrew Lutomirski <luto@mit.edu>, Indan Zupancic <indan@nul.nu>,
        linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
        linux-doc@vger.kernel.org, kernel-hardening@lists.openwall.com,
        netdev@vger.kernel.org, x86@kernel.org, arnd@arndb.de,
        davem@davemloft.net, mingo@redhat.com, oleg@redhat.com,
        peterz@infradead.org, rdunlap@xenotime.net, tglx@linutronix.de,
        eparis@redhat.com, serge.hallyn@canonical.com, djm@mindrot.org,
        scarybeasts@gmail.com, pmoore@redhat.com, akpm@linux-foundation.org,
        corbet@lwn.net, eric.dumazet@gmail.com, markus@chromium.org
To: Roland McGrath <mcgrathr@google.com>
Return-path: <kernel-hardening-return-928-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <CAB=4xhq1sm_ewZ_8Kerf2aN7nGx+DEENse7Lqg5N0wuvqtzUAw@mail.gmail.com>
List-Id: netdev.vger.kernel.org

On 02/22/2012 04:50 PM, Roland McGrath wrote:
> On Wed, Feb 22, 2012 at 4:29 PM, H. Peter Anvin <hpa@zytor.com> wrote:
>> Can we really introduce force-kill semantics for a POSIX-defined signal?
>> Other user space programs might use it for other purposes.
> 
> The semantics are based on how the signal was generated, not what signal
> number it was.  The only thing that depends on the signal number is
> SYNCHRONOUS_MASK, which just determines in which order pending signals are
> dequeued (POSIX says it may be any order).  We only have that so your state
> doesn't get unhelpfully warped to another signal handler entry point
> (including fiddling the stack) before you dump core.
> 
> No use of SIGSYS is specified by POSIX at all, of course, since "system
> call" is an implementation concept below the level POSIX specifies.

I meant whether or not a signal can be blocked/caught and the fact that
the signal exists at all.

Now I guess we could have "blockable" and "unblockable" SIGSYS, but that
would seem to have its own set of issues...

	-hpa

-- 
H. Peter Anvin, Intel Open Source Technology Center
I work for Intel.  I don't speak on their behalf.
