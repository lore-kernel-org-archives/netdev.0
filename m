From: Paul Bolle <pebolle@tiscali.nl>
Subject: Re: [PATCH 32/58] isdn/gigaset: Convert timers to use timer_setup()
Date: Thu, 19 Oct 2017 23:51:47 +0200
Message-ID: <1508449907.2274.28.camel@tiscali.nl>
References: <1508200182-104605-1-git-send-email-keescook@chromium.org>
                 <1508200182-104605-33-git-send-email-keescook@chromium.org>
                 <1508447002.2274.14.camel@tiscali.nl>
         <1508448028.2274.21.camel@tiscali.nl>
         <alpine.DEB.2.20.1710192328110.2054@nanos>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Kees Cook <keescook@chromium.org>,
        "David S. Miller" <davem@davemloft.net>,
        Karsten Keil <isdn@linux-pingi.de>,
        Johan Hovold <johan@kernel.org>,
        gigaset307x-common@lists.sourceforge.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.20.1710192328110.2054@nanos>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2017-10-19 at 23:31 +0200, Thomas Gleixner wrote:
> bas_gigaset_exit()
> {
>         for (i = 0; i < driver->minors; i++) {
>                 if (gigaset_shutdown(driver->cs + i) < 0)
> 
> gigaset_shutdown(cs)
> {
> 	mutex_lock(&cs->mutex); <-------- Explodes here
> 
> So driver->cs + i is invalid. No idea how that might be related to that
> timer conversion patch, but ....

Thanks for peeking into this!

Please note that driver->minors is one of the more embarrassing warts of the
gigaset code. It's basically hardcoded to 1 for all three drivers (including
bas_gigaset). So driver->cs itself is invalid here.

And since the patch uses
    struct cardstate *cs = urb->context;

in a few places my guess is that it's really the patch that triggers this.

Thanks,


Paul Bolle
