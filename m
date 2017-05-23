From: Kees Cook <keescook-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [kernel-hardening] [PATCH v4 next 0/3] modules: automatic module
 loading restrictions
Date: Tue, 23 May 2017 11:36:36 -0700
Message-ID: <CAGXu5jJ-zpqU9v44=bc0GnQP5zcKtceR_7DBQVBZ=vy3OvNx9w@mail.gmail.com>
References: <1495454226-10027-1-git-send-email-tixxdz@gmail.com>
 <20170522120848.GA3003@openwall.com> <CAEiveUdqfMk4+vLg6TaEJNSGwoQHxYq0P4aqZoL4i9GgR3Vdtw@mail.gmail.com>
 <20170522164323.GA2048@openwall.com> <CAEiveUdb=yc5Gt_+pU_hfNdoNBP0JsUL1QUydNZgc2tD7n1h1w@mail.gmail.com>
 <CAGXu5jKGnG74KE-k9JPaH1bNqT5nbVioaeu_5sAKQ+4kgp-0Ng@mail.gmail.com> <20170523074808.GA4562@openwall.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Djalal Harouni <tixxdz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        LSM List <linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "kernel-hardening-ZwoEplunGu1jrUoiu81ncdBPR1lH4CV8@public.gmane.org"
        <kernel-hardening-ZwoEplunGu1jrUoiu81ncdBPR1lH4CV8@public.gmane.org>,
        Andy Lutomirski <luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
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
        Linux API <linux-api-u79uwXL29TaqPxH82wqD4g@public.gmane.org
To: Solar Designer <solar-cxoSlKxDwOJWk0Htik3J/w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170523074808.GA4562-cxoSlKxDwOJWk0Htik3J/w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, May 23, 2017 at 12:48 AM, Solar Designer <solar-cxoSlKxDwOJWk0Htik3J/w@public.gmane.org> wrote:
> For modules_autoload_mode=2, we already seem to have the equivalent of
> modprobe=/bin/true (or does it differ subtly, maybe in return values?),
> which I already use at startup on a GPU box like this (preloading
> modules so that the OpenCL backends wouldn't need the autoloading):
>
> nvidia-smi
> nvidia-modprobe -u -c=0
> #modprobe nvidia_uvm
> #modprobe fglrx
>
> sysctl -w kernel.modprobe=/bin/true
> sysctl -w kernel.hotplug=/bin/true
>
> but it's good to also have this supported more explicitly and more
> consistently through modules_autoload_mode=2 while we're at it.  So I
> support having this mode as well.  I just question the need to have it
> non-resettable.

I agree it's useful to have the explicit =2 state just to avoid
confusion when more systems start implementing
CONFIG_STATIC_USERMODEHELPER and kernel.modprobe becomes read-only
(though the userspace implementation may allow for some way to disable
it, etc). I just like avoiding the upcall to modprobe at all.

-Kees

-- 
Kees Cook
Pixel Security
