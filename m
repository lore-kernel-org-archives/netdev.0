From: Mika Westerberg <mika.westerberg-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Subject: Re: [PATCH RFC 4/6] net: rfkill: gpio: add device tree support
Date: Wed, 22 Jan 2014 13:00:11 +0200
Message-ID: <20140122110011.GU18029@intel.com>
References: <1389941251-32692-1-git-send-email-wens@csie.org>
 <CAAVeFuLP4MkfXGG1FMauvUw_J63zRXdhGwxqYy5W98L1wCQNbw@mail.gmail.com>
 <CACRpkdYiy+sya6NqRfAmsrFOXvaa3qX=qjRuTDW1vZVSaG1+Gg@mail.gmail.com>
 <201401211335.16885.arnd@arndb.de>
 <CAAVeFuKFfAvSPYLmvWV5jjT-peZFJ8sJ2bbh4F=JAYoWLhjZpA@mail.gmail.com>
 <CACRpkdZbb=eO8YRtMn6hW0vn97PkHUo88e_o61DEC8=wPY3_PQ@mail.gmail.com>
Reply-To: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Alexandre Courbot <gnurou-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
	"linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org" <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Heikki Krogerus <heikki.krogerus-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-sunxi <linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
	linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
	Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"linux-gpio-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-gpio-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Linus Walleij <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Return-path: <linux-sunxi+bncBDKLLFXN7AKBBFWG72LAKGQE36EOVDQ-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
In-Reply-To: <CACRpkdZbb=eO8YRtMn6hW0vn97PkHUo88e_o61DEC8=wPY3_PQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Post: <http://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <http://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <http://groups.google.com/group/linux-sunxi>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Subscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Content-Disposition: inline
List-Id: netdev.vger.kernel.org

On Wed, Jan 22, 2014 at 10:58:38AM +0100, Linus Walleij wrote:
> On Tue, Jan 21, 2014 at 3:53 PM, Alexandre Courbot <gnurou-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> 
> > The good (or bad, rather) thing about DT is that we can do whatever we
> > please with the new bindings: decide which name or which index
> > (doesn't matter here) a GPIO should have. However we don't have this
> > control over ACPI, where nothing guarantees that the same index will
> > be used for the same GPIO function.
> 
> It's not like ACPI will impose some tables on us and expect us to
> use them as-is no matter how crazy they are. Then indeed the whole
> idea of unifying ACPI and DT accessors would be moot and it would
> only work by mistake or as a good joke.

With the current ACPI version we really don't have much of a choice here.
Only way we can distinguish between a set of GPIOs is to use index and hope
that the vendor puts the GPIOs in the table in same order that the driver
expects :-(

This is going to get a bit better when ACPI gets properties (like Arnd
commented already) as then we can get the correct index based on a name in
a table. However, it still requires the vendor to use naming that is
suitable for Linux driver in question.

> The situation with ACPI is just like with DT, it is assumed that the
> author of these tables also look at the Linux kernel drivers to figure
> out what argument goes where and we can influence them.

I certainly hope, now that Android is becoming more and more important,
that the vendors will actually check what the Linux drivers expect and
populate the tables with such information that is suitable for both ACPI
and DT enabled driver.
