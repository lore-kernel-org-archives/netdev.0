From: Kees Cook <keescook@chromium.org>
Subject: Re: tip -ENOBOOT - bisected to locking/refcounts, x86/asm: Implement
 fast refcount overflow protection
Date: Thu, 31 Aug 2017 12:28:40 -0700
Message-ID: <CAGXu5jKRNXGqN8=90qy1NJQ1bmzKCfjJPhY1Ewi9wLE5VofwRQ@mail.gmail.com>
References: <1503996623.8323.20.camel@gmx.de> <CAGXu5jLYHy6Damtg_Pc4=G76OUiMV3fcY9+Ru1-Lmiq6VWEgsw@mail.gmail.com>
 <1504025721.6024.25.camel@gmx.de> <1504030207.6560.0.camel@gmx.de>
 <CAGXu5jKSWiZ8NkgUqO6G8fs5R06bMtdFBmZz9MMX-HAk8nXXNw@mail.gmail.com>
 <1504069332.8352.3.camel@gmx.de> <CAGXu5jJim=r8b+y1qQXtuzm9fPyv1tp9ANebxbCc9ic2c83_Mg@mail.gmail.com>
 <1504113212.5852.6.camel@gmx.de> <CAGXu5jJd80-0PJvB51x9ZDETPSoAtRVQ7dQ6HWwd0DYpKBgPFA@mail.gmail.com>
 <1504115735.5852.11.camel@gmx.de> <CAGXu5j+BLj6_LPfKs-vts-mbyJHu8D--WrmWbiT8Zbt-iD65KA@mail.gmail.com>
 <CAGXu5j+neSYAqb8=r42=jQ0LsJTGjCSdpgc9Hv+ipyAFURbCdw@mail.gmail.com>
 <1504145389.23109.4.camel@gmx.de> <CAGXu5jLKXEDdSpxxVM5oHHUWKbSTozx4FZRn70bQm4tQAhMqUQ@mail.gmail.com>
 <1504149176.23109.9.camel@gmx.de> <CAGXu5j+uNU+wqWoCV+Kpdp+DQer4E3VuwO0mtXiW3Dtw_61QKA@mail.gmail.com>
 <CAGXu5jKYPp5D+YxtqrJXsi48UUbjfeREngsys-dU1eP4RnnL+w@mail.gmail.com> <1504187918.27500.16.camel@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "David S. Miller" <davem@davemloft.net>,
        Peter Zijlstra <peterz@infradead.org>,
        LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>,
        "Reshetova, Elena" <elena.reshetova@intel.com>,
        Network Development <netdev@vger.kernel.org>
To: Mike Galbraith <efault@gmx.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1504187918.27500.16.camel@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 31, 2017 at 6:58 AM, Mike Galbraith <efault@gmx.de> wrote:
> gdb) list *in6_dev_get+0x10
> 0xffffffff8166d3d0 is in in6_dev_get (./include/net/addrconf.h:318).
> 313     {
> 314             struct inet6_dev *idev;
> 315
> 316             rcu_read_lock();
> 317             idev = rcu_dereference(dev->ip6_ptr);
> 318             if (idev)
> 319                     refcount_inc(&idev->refcnt);
> 320             rcu_read_unlock();
> 321             return idev;
> 322

And this is a completely different refcount from the other that
tripped. This one is quite simple, too, though I see it uses
refcount_dec(), which is a path to saturation. I've sent a patch to
try to clarify this further...

-Kees

-- 
Kees Cook
Pixel Security
