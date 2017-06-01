From: Kees Cook <keescook@google.com>
Subject: Re: [PATCH v4 next 1/3] modules:capabilities: allow
 __request_module() to take a capability argument
Date: Thu, 1 Jun 2017 12:10:07 -0700
Message-ID: <CAGXu5jJPk5a_66FpMd6D-XdWyzD7sxCPQirz1C6_hEFu4qsP5g@mail.gmail.com>
References: <1495454226-10027-1-git-send-email-tixxdz@gmail.com>
 <1495454226-10027-2-git-send-email-tixxdz@gmail.com> <CAGXu5jL9jRDkHj20kf4O6VrjiEpvXGzN3nn5Lw4fT2sx_Xg=+A@mail.gmail.com>
 <CAEiveUe5cTCet6=Uzn64YANRZ2Qyqk5OSXqU3MybevbkbeNR3Q@mail.gmail.com>
 <CAGXu5j+L1aEWqi7DC4StwAorfG4da0XqrouMvbz07cJ7gYi0AQ@mail.gmail.com>
 <CAEiveUeZhHtPyLv8=3BsPh5Anr2ynnzD0bprUkeKUGygtRQKsw@mail.gmail.com>
 <CAGXu5jK5exWBV+ub8ys86Ubu1vKwN=miOZxwp3zdWaWEfuJddQ@mail.gmail.com> <CAEiveUeKU-zxXUeeuTZ2Sf1NrbH+t9JjwaWOK_2varRDsfbEWg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "Serge E. Hallyn" <serge@hallyn.com>,
        Rusty Russell <rusty@rustcorp.com.au>,
        "David S . Miller" <davem@davemloft.net>,
        Jessica Yu <jeyu@redhat.com>,
        LKML <linux-kernel@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        linux-security-module <linux-security-module@vger.kernel.org>,
        "kernel-hardening@lists.openwall.com"
        <kernel-hardening@lists.openwall.com>,
        Andy Lutomirski <luto@kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        James Morris <james.l.morris@oracle.com>,
        Paul Moore <paul@paul-moore.com>,
        Stephen Smalley <sds@tycho.nsa.gov>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
        Ingo Molnar <mingo@kernel.org>,
        Linux API <linux-api@vger.kernel.org>,
        Dongsu Park <dpar
To: Djalal Harouni <tixxdz@gmail.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <CAEiveUeKU-zxXUeeuTZ2Sf1NrbH+t9JjwaWOK_2varRDsfbEWg@mail.gmail.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 1, 2017 at 7:56 AM, Djalal Harouni <tixxdz@gmail.com> wrote:
>         module_require_cap = 0;
>
>         if (autoload == MODULES_AUTOLOAD_DISABLED)
>                 return -EPERM;
>
>         if (autoload == MODULES_AUTOLOAD_PRIVILEGED || require_cap > 0) {
>                 if (prefix != NULL && *prefix != '\0')
>                         /*
>                          * Allow non-CAP_SYS_MODULE caps when
>                          * using a distinct prefix.
>                          */
>                         module_require_cap = require_cap;
>                 else
>                         /*
>                          * Otherwise always require CAP_SYS_MODULE if no
>                          * valid prefix. Callers that do not provide a valid prefix
>                          * should not provide a require_cap > 0
>                          */
>                         module_require_cap = CAP_SYS_MODULE;
>         }
>
>         /* If autoload allowed and 'module_require_cap' was *never* set, allow */
>         if (module_require_cap == 0 && autoload == MODULES_AUTOLOAD_ALLOWED)
>                 return 0;
>
>         return capable(module_require_cap) ? 0 : -EPERM;
>
> Maybe you will agree :-) ?

Yes! Looks good. I was accidentally still thinking about the caps
checks being in the net code, but obviously, that wouldn't be the case
anymore. Thanks for the catch. :)

> BTW Kees, also in next version I won't remove the
> capable(CAP_NET_ADMIN) check from [1]
> even if there is the new request_module_cap(), I would like it to be
> in a different patches, this way we go incremental
> and maybe it is better to merge what we have now ?  and follow up
> later, and of course if other maintainers agree too!

Yes, incremental. I would suggest first creating the API changes to
move a basic require_cap test into the LSM (which would drop the
open-coded capable() checks in the net code), and then add the
autoload logic in the following patches. That way the "infrastructure"
changes happen separately and do not change any behaviors, but moves
the caps test down where its wanted in the LSM, before then augmenting
the logic.

> I just need a bit of free time to check again everything and will send
> a v5 with all requested changes.

Great, thank you!

-Kees

-- 
Kees Cook
Pixel Security
