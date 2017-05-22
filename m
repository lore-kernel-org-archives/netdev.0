From: Djalal Harouni <tixxdz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [kernel-hardening] [PATCH v4 next 0/3] modules: automatic module
 loading restrictions
Date: Mon, 22 May 2017 21:55:41 +0200
Message-ID: <CAEiveUdb=yc5Gt_+pU_hfNdoNBP0JsUL1QUydNZgc2tD7n1h1w@mail.gmail.com>
References: <1495454226-10027-1-git-send-email-tixxdz@gmail.com>
 <20170522120848.GA3003@openwall.com> <CAEiveUdqfMk4+vLg6TaEJNSGwoQHxYq0P4aqZoL4i9GgR3Vdtw@mail.gmail.com>
 <20170522164323.GA2048@openwall.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        LSM List <linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        kernel-hardening-ZwoEplunGu1jrUoiu81ncdBPR1lH4CV8@public.gmane.org,
        Andy Lutomirski <luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
        Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
        Rusty Russell <rusty-8n+1lVoiYb80n/F98K4Iww@public.gmane.org>,
        "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>, Jessica Yu <jeyu-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        James Morris <james.l.morris-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
        Paul Moore <paul-r2n+y4ga6xFZroRs9YW3xA@public.gmane.org>,
        Stephen Smalley <sds-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>,
        Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
        Tetsuo Handa <penguin-kernel-1yMVhJb1mP/7nzcFbJAaVXf5DAMn2ifp@public.gmane.org>,
        Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Dongsu Park <dpark-VwIFZPTo/vqsTnJN9+BGXg@public.gmane.org>,
        Casey Schaufler <ca
To: Solar Designer <solar-cxoSlKxDwOJWk0Htik3J/w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170522164323.GA2048-cxoSlKxDwOJWk0Htik3J/w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, May 22, 2017 at 6:43 PM, Solar Designer <solar-cxoSlKxDwOJWk0Htik3J/w@public.gmane.org> wrote:
> On Mon, May 22, 2017 at 03:49:15PM +0200, Djalal Harouni wrote:
>> On Mon, May 22, 2017 at 2:08 PM, Solar Designer <solar-cxoSlKxDwOJWk0Htik3J/w@public.gmane.org> wrote:
>> > On Mon, May 22, 2017 at 01:57:03PM +0200, Djalal Harouni wrote:
>> >> *) When modules_autoload_mode is set to (2), automatic module loading is
>> >> disabled for all. Once set, this value can not be changed.
>> >
>> > What purpose does this securelevel-like property ("Once set, this value
>> > can not be changed.") serve here?  I think this mode 2 is needed, but
>> > without this extra property, which is bypassable by e.g. explicitly
>> > loaded kernel modules anyway (and that's OK).
>>
>> My reasoning about "Once set, this value can not be changed" is mainly for:
>>
>> If you have some systems where modules are not updated for any given
>> reason, then the only one who will be able to load a module is an
>> administrator, basically this is a shortcut for:
>>
>> * Apps/services can run with CAP_NET_ADMIN but they are not allowed to
>> auto-load 'netdev' modules.
>>
>> * Explicitly loading modules can be guarded by seccomp filters *per*
>> app, so even if these apps have
>>   CAP_SYS_MODULE they won't be able to explicitly load modules, one
>> has to remount some sysctl /proc/ entries read-only here and remove
>> CAP_SYS_ADMIN for all apps anyway.
>>
>> This mainly serves the purpose of these systems that do not receive
>> updates, if I don't want to expose those kernel interfaces what should
>> I do ? then if I want to unload old versions and replace them with new
>> ones what operation should be allowed ? and only real root of the
>> system can do it. Hence, the "Once set, this value can not be changed"
>> is more of a shortcut, also the idea was put in my mind based on how
>> "modules_disabled" is disabled forever, and some other interfaces. I
>> would say: it is easy to handle a transition from 1) "hey this system
>> is still up to date, some features should be exposed" to 2) "this
>> system is not up to date anymore, only root should expose some
>> features..."
>>
>> Hmm, I am not sure if this answers your question ? :-)
>
> This answers my question, but in a way that I summarize as "there's no
> good reason to include this securelevel-like property".
>

Hmm, sorry I did forget to add in my previous comment that with such
systems, CAP_SYS_MODULE can be used to reset the
"modules_autoload_mode" sysctl back from mode 2 to mode 1, even if we
disable it privileged tasks can be triggered to overwrite the sysctl
flag and get it back unless /proc is read-only... that's one of the
points, it should not be so easy to relax it.



>> I definitively don't want to fall into "modules_disabled" trap where
>> is it too strict! "Once set, this value can not be changed" means for
>> some users do not set it otherwise the system is unusable...
>>
>> Maybe an extra "4" mode for that ? better get it right.
>
> I think you should simply exclude this property from mode 2.
>

Ok, maybe my comment above answers this ?

What I was referring to here, is to have one small window where it is
disable for privileged and that securelevel-like like property or
disable definitively are separated. I don't have a strong opinion
here, having a usable system is important.


> The module autoloading restrictions aren't meant to reduce root's
> powers; they're only meant to protect processes from shooting themselves
> and the system in the foot inadvertently (confused deputy).
>
> modules_disabled may be different in that respect, although with the
> rest of the kernel lacking securelevel-like support the point is moot.
>
> We had working securelevel in 2.0.34 through 2.0.40 inclusive, but
> we've lost it in 2.1+ with cap-bound apparently never becoming as
> complete a replacement for it and having been lost/broken further in
> 2.6.25+.  I regret this, but that's a different story.  Like I say,
> module autoloading doesn't even fit in with those restrictions - it's
> about a totally different threat model.
>

Ok, thanks for the information, so yes it seems we do not have such a
consistent way, but this did not block Yama LSM and other sysctl to
implement their own cases, maybe it did show that it is not that easy
to have a generic securelevel mechanism ? and what we currently have
is more practical ? I can't tell here. But we definitively want to
block privileged tasks to revert the sysctl mode if the administrator
do not want automatic module loading.

Thanks!

-- 
tixxdz
