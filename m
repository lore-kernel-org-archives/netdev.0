From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH 2/2] net: dsa: register hwmon for any provided function
Date: Fri, 17 Apr 2015 10:45:04 -0400 (EDT)
Message-ID: <164492855.190846.1429281904066.JavaMail.zimbra@savoirfairelinux.com>
References: <1429209499-2447-1-git-send-email-vivien.didelot@savoirfairelinux.com> <1429209499-2447-2-git-send-email-vivien.didelot@savoirfairelinux.com> <20150416212638.GB2587@roeck-us.net> <973411308.896485.1429221939679.JavaMail.zimbra@savoirfairelinux.com> <55306D40.1060604@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	kernel@savoirfairelinux.com
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55306D40.1060604@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Guenter,

> >>>           switch (index) {
> >>> +        case 0: /* temp1_input */
> >>> +                if (drv->get_temp)
> >>> +                        mode |= S_IRUGO;
> >>
> >> This should be mandatory. Sorry, I don't really understand what you
> >> are trying to accomplish here.
> >>
> >> Can you give me a real world example where a chip would support
> >> setting a limit but not reading it ?
> >
> > I have no such example. I just did not see why this couldn't be
> > allowed (e.g. setting only set_temp_limit and get_temp_alarm looks
> > fine to me).  But if you say that get_temp should be mandatory, I'm
> > OK with that.
> >
> write-only attributes are not defined in the hwmon ABI. If the
> 'sensors' command encounters such an attribute, it will create an
> error message each time it executes. That doesn't sound very useful to
> me.

Ok, good to know.

> If a chip - for whatever reason - does not have a limit register but
> an alarm register or flag, its temperature limit is usually hard-coded
> and can be reported this way (the AMD temperature sensor driver does
> this, for example). If there is ever a need to support the
> alarm-register-only situation for some odd reason, we can add the code
> at the time.  For now, it just seems to me that you are adding
> complexity to solve some theoretic problem which is very unlikely to
> occur in the real world.

You're right, this change is not necessary.

> > The primary goal of this patchset was to use DEVICE_ATTR_RW to
> > declare temp1_max, instead of reflecting the minimal permissions
> > needed.
> >
> Then why don't you just do that and nothing else ? The goal should be
> to simplify code, not to make it more complicated. If the result isn't
> less code, I don't think it is worth it.

Indeed, I'll rework this patch then.

Thanks for the review,
-v
