From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: [PATCH v10 07/11] signal, x86: add SIGSYS info and make it synchronous.
Date: Wed, 22 Feb 2012 16:29:46 -0800
Message-ID: <4F45887A.5010809@zytor.com>
References: <1329845435-2313-1-git-send-email-wad@chromium.org> <1329845435-2313-7-git-send-email-wad@chromium.org> <9edbabb2262e3d91a7b8c75dbec03d7f.squirrel@webmail.greenhost.nl> <CABqD9hY1n9EOAKKT0r9Ev+azhBMnLMAM_FgDNe5we9upVePk_A@mail.gmail.com> <CAObL_7Gc0U2JMBQr_kbcVUJwyJq7LRfgdFr+84LR=ec4kSCwEA@mail.gmail.com> <CAGXu5jJQrnkCZtcLqK8NEihRgB25C12b0nKp+XWXV_=4QfcVoA@mail.gmail.com> <CABqD9hbC8v-rUBW+4T_-EwDwe1+VDohQZweQ-cxOg2A-iDH5CQ@mail.gmail.com> <CAGXu5j+fQqkrrKSm3kmCkCcZJKo-VZjL6kkrOD81LZYBY7tf2g@mail.gmail.com>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Will Drewry <wad@chromium.org>, Andrew Lutomirski <luto@mit.edu>,
        Indan Zupancic <indan@nul.nu>, linux-kernel@vger.kernel.org,
        linux-arch@vger.kernel.org, linux-doc@vger.kernel.org,
        kernel-hardening@lists.openwall.com, netdev@vger.kernel.org,
        x86@kernel.org, arnd@arndb.de, davem@davemloft.net, mingo@redhat.com,
        oleg@redhat.com, peterz@infradead.org, rdunlap@xenotime.net,
        mcgrathr@chromium.org, tglx@linutronix.de, eparis@redhat.com,
        serge.hallyn@canonical.com, djm@mindrot.org, scarybeasts@gmail.com,
        pmoore@redhat.com, akpm@linux-foundation.org, corbet@lwn.net,
        eric.dumazet@gmail.com, markus@chromium.org
To: Kees Cook <keescook@chromium.org>
Return-path: <kernel-hardening-return-926-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <CAGXu5j+fQqkrrKSm3kmCkCcZJKo-VZjL6kkrOD81LZYBY7tf2g@mail.gmail.com>
List-Id: netdev.vger.kernel.org

On 02/22/2012 04:08 PM, Kees Cook wrote:
>>
>> Hrm, it might be possible to do_exit(SIGSYS) which would be both. It
>> looks like tsk->exit_code would be SIGSYS then, but I'll look a little
>> more closely to see what that'll actually do.
> 
> As long as there's no way it can get blocked, I'd be fine with that.
> It would, actually, be better than SIGKILL because, as Andy said, it's
> more distinguishable from other situations. I've long wanted a signal
> to be used for "violated policy" that wasn't just a straight SIGKILL.
> 

Can we really introduce force-kill semantics for a POSIX-defined signal?
 Other user space programs might use it for other purposes.

I'm wondering if the right thing may be to introduce some variant of
exit() which can return more information about a signal, including some
kind of cause code for SIGKILL?

	-hpa

-- 
H. Peter Anvin, Intel Open Source Technology Center
I work for Intel.  I don't speak on their behalf.
