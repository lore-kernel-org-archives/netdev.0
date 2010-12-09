From: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] atm: correct sysfs 'device' link creation and parent
 relationships
Date: Wed, 08 Dec 2010 18:33:49 -0600
Message-ID: <1291854831.16839.12.camel@dcbw.foobar.com>
References: <1291587480.17538.12.camel@dcbw.foobar.com>
	 <AANLkTikhkVPcibAH8cSRvZSLop=Ew19Tn=KtY7prkKUn@mail.gmail.com>
	 <20101208.101121.71114237.davem@davemloft.net>
	 <20101208.121532.232745367.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: kay.sievers-tD+1rO4QERM@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, duncan.sands-GANU6spQydw@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, chas-vT06rRrALxcmhCb6mdbn6A@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20101208.121532.232745367.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 2010-12-08 at 12:15 -0800, David Miller wrote:
> From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
> Date: Wed, 08 Dec 2010 10:11:21 -0800 (PST)
> 
> > From: Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>
> > Date: Tue, 7 Dec 2010 08:35:53 +0100
> > 
> >> On Sun, Dec 5, 2010 at 23:17, Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> >>> The ATM subsystem was incorrectly creating the 'device' link for ATM
> >>> nodes in sysfs.  This led to incorrect device/parent relationships
> >>> exposed by sysfs and udev.  Instead of rolling the 'device' link by hand
> >>> in the generic ATM code, pass each ATM driver's bus device down to the
> >>> sysfs code and let sysfs do this stuff correctly.
> >> 
> >> Looks good to me.
> > 
> > I've applied this to net-2.6, thanks Dan.
> 
> Actually I'm reverting, it breaks the build.
> 
> Did you even grep for "atm_dev_register()" after changning the number
> of arguments, or were you depending upon build failures to guide you?

What seems to have happened here was that I built against my installed
kernel config, which apparently does not enable a few of the drivers,
and thus I missed the error.  I apologize, I will submit a new patch,
and I will not let this happen again.

Dan

> Please never do the latter, as it always leads to things like this.
> 
> drivers/atm/fore200e.c:2577:7: error: too few arguments to function 'atm_dev_register'
> drivers/atm/iphase.c:3175:2: error: too few arguments to function 'atm_dev_register'



--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
