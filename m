From: Kevin Easton <kevin@guarana.org>
Subject: Re: [PATCH 05/14] isdn: isdnloop: suppress a gcc-7 warning
Date: Sat, 15 Jul 2017 00:20:23 -0400
Message-ID: <20170715042022.GA18345@la.guarana.org>
References: <20170714092540.1217397-1-arnd@arndb.de>
 <20170714092540.1217397-6-arnd@arndb.de>
 <1500026936.4457.68.camel@perches.com>
 <CAK8P3a2fYr11L-0sg-veKx5F5dGH5btQAhSZtFbNXxVtcHd8dg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Joe Perches <joe@perches.com>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Karsten Keil <isdn@linux-pingi.de>,
        "David S. Miller" <davem@davemloft.net>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Tejun Heo <tj@kernel.org>, Guenter Roeck <linux@roeck-us.net>,
        IDE-ML <linux-ide@vger.kernel.org>,
        Linux Media Mailing List <linux-media@vger.kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        dri-devel <dri-devel@lists.freedesktop.org>,
        Networking <netdev@vger.kernel.org>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAK8P3a2fYr11L-0sg-veKx5F5dGH5btQAhSZtFbNXxVtcHd8dg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 14, 2017 at 12:37:05PM +0200, Arnd Bergmann wrote:
> On Fri, Jul 14, 2017 at 12:08 PM, Joe Perches <joe@perches.com> wrote:
> > On Fri, 2017-07-14 at 11:25 +0200, Arnd Bergmann wrote:
> >> We test whether a bit is set in a mask here, which is correct
> >> but gcc warns about it as it thinks it might be confusing:
> >>
> >> drivers/isdn/isdnloop/isdnloop.c:412:37: error: ?: using integer constants in boolean context, the expression will always evaluate to 'true' [-Werror=int-in-bool-context]

...

> > Perhaps this is a logic defect and should be:
> >
> >                 if (!(card->flags & ((channel) ? ISDNLOOP_FLAGS_B2ACTIVE : ISDNLOOP_FLAGS_B1ACTIVE)))
> 
> Yes, good catch. I had thought about it for a bit whether that would be
> the answer, but come to the wrong conclusion on my own.
> 
> Note that the version you suggested will still have the warning, so I think
> it needs to be

It shouldn't - the warning is for using an integer *constant* in boolean
context, but the result of & isn't a constant and should be fine.

!(flags & mask) is a very common idiom.

    - Kevin 
