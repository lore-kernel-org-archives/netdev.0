From: Paul Bolle <pebolle@tiscali.nl>
Subject: Re: [PATCH 32/58] isdn/gigaset: Convert timers to use timer_setup()
Date: Fri, 20 Oct 2017 01:31:39 +0200
Message-ID: <1508455899.2274.73.camel@tiscali.nl>
References: <1508200182-104605-1-git-send-email-keescook@chromium.org>
                  <1508200182-104605-33-git-send-email-keescook@chromium.org>
                  <1508447002.2274.14.camel@tiscali.nl>
          <1508448028.2274.21.camel@tiscali.nl>
          <alpine.DEB.2.20.1710192328110.2054@nanos>
         <1508449907.2274.28.camel@tiscali.nl>
         <alpine.DEB.2.20.1710200025470.2054@nanos>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        Kees Cook <keescook@chromium.org>,
        "David S. Miller" <davem@davemloft.net>,
        Karsten Keil <isdn@linux-pingi.de>,
        Johan Hovold <johan@kernel.org>,
        gigaset307x-common@lists.sourceforge.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.20.1710200025470.2054@nanos>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[CC-ing Linus because I quote him.]

On Fri, 2017-10-20 at 00:28 +0200, Thomas Gleixner wrote:
> Well, that does not explain why
> 
>       drivers->cs + i
> 
> would be corrupted. That would require that this cs -> urb link points at
> driver magically and then wreckages that driver data structure. Might be
> the case, but if so then there are dragons burried somehwere

Let's assume dragons are buried somewhere.

We need users to show us that they met a dragon, right? (I care little about
dragons no-one ever stumbles upon.)

In the explanation of commit 9f5af546e6ac ("isdn/i4l: fix buffer overflow")
Linus added:
    [ ISDN seems to be effectively unmaintained, and the I4L driver in
      particular is long deprecated, but in case somebody uses this..
        - Linus ]

ISDN is pretty niche. So it's no surprise that in mainline it's divided into
three parts: I4L, CAPI, and mISDN.

Arnd Bergmann has suggested more than once to move I4L to staging. (As far as
I know, moving drivers to staging effectively means removing those drivers,
but anyhow.) I'd say we'd just should do that. The stuff has been deemed
deprecated since basically forever.

I never cared about mISDN, but as far as I can see mISDN has quietly left
mainline.

The only actively maintained CAPI drivers are gigaset's drivers. But I'm
afraid maintaining gigaset basically means seeing treewide cleanups fly by and
  keeping the various fuzzers happy. I don't mind, and I could keep on doing
that for years. But still, I'd love to hear someone say: yes, I still care
about mainline ISDN.

Does that person still exists?

Thanks,


Paul Bolle
