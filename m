From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: netlink backwards compatibility in userspace tools
Date: Fri, 29 Sep 2017 08:21:11 -0700
Message-ID: <20170929082111.50e0c972@xeon-e3>
References: <CAHmME9oixZtPVdH24KJQ9NaTuf_ECAOoHwQhuA+Fy-BX+F_3dw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Daniel Kahn Gillmor <dkg@fifthhorseman.net>
To: "Jason A. Donenfeld" <Jason@zx2c4.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAHmME9oixZtPVdH24KJQ9NaTuf_ECAOoHwQhuA+Fy-BX+F_3dw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 29 Sep 2017 12:22:42 +0200
"Jason A. Donenfeld" <Jason@zx2c4.com> wrote:

> Hi guys,
> 
> One handy aspect of Netlink is that it's backwards compatible. This
> means that you can run old userspace utilities on new kernels, even if
> the new kernel supports new features and netlink attributes. The wire
> format is stable enough that the data marshaled can be extended
> without breaking compat. Neat.
> 
> I was wondering, though, what you think the best stance is toward
> these old userspace utilities. What should they do if the kernel sends
> it netlink attributes that it does not recognize? At the moment, I'm
> doing something like this:
> 
> static void warn_unrecognized(void)
> {
>     static bool once = false;
>     if (once)
>         return;
>     once = true;
>     fprintf(stderr,
>         "Warning: this program received from your kernel one or more\n"
>         "attributes that it did not recognize. It is possible that\n"
>         "this version of wg(8) is older than your kernel. You may\n"
>         "want to update this program.\n");
> }
> 
> This seems like a somewhat sensible warning, but then I wonder about
> distributions like Debian, which has a long stable life cycle, so it
> frequently has very old tools (ancient iproute2 for example). Then,
> VPS providers have these Debian images run on top of newer kernels.
> People in this situation would undoubtedly see the above warning a lot
> and not be able to do anything about it. Not horrible, but a bit
> annoying. Is this an okay annoyance? Or is it advised to just have no
> warning at all? One idea would be to put it behind an environment
> variable flag, but I don't like too many nobs.
> 
> I'm generally wondering about attitudes toward this kind of userspace
> program behavior in response to newer kernels.
> 
> Thanks,
> Jason

I can not see a reason that such a warning is required.
Old utilities should just work fine, they just won't show or allow
setting attributes they don't understand.

Any netlink attributes that the tools do not recognize should just
be ignored.
