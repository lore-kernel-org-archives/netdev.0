From: Edward Cree <ecree@solarflare.com>
Subject: Re: [PATCH 1/4] kconfig: introduce the "imply" keyword
Date: Thu, 20 Oct 2016 18:41:02 +0100
Message-ID: <fea29738-142d-0cb8-da85-cf376d1158e7@solarflare.com>
References: <1476920573-14384-1-git-send-email-nicolas.pitre@linaro.org>
 <1476920573-14384-2-git-send-email-nicolas.pitre@linaro.org>
 <44f95579-6c35-7592-08e3-d8dbb13026b2@solarflare.com>
 <alpine.LFD.2.20.1610201245230.25105@knanqh.ubzr>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8BIT
Cc: John Stultz <john.stultz@linaro.org>,
        Richard Cochran <richardcochran@gmail.com>,
        Yann E MORIN <yann.morin.1998@free.fr>,
        "Thomas Gleixner" <tglx@linutronix.de>,
        Josh Triplett <josh@joshtriplett.org>,
        <netdev@vger.kernel.org>, <linux-kbuild@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
To: Nicolas Pitre <nicolas.pitre@linaro.org>
Return-path: <linux-kbuild-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.20.1610201245230.25105@knanqh.ubzr>
Sender: linux-kbuild-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 20/10/16 18:04, Nicolas Pitre wrote:
> On Thu, 20 Oct 2016, Edward Cree wrote:
>> Also, I don't think having any FOO=y should preclude BAZ=m.  Suppose both
>> FOO and FOO2 imply BAZ, FOO=y and FOO2=m.
> Some people didn't like the fact that you could turn a driver from m to
> y and silently lose some features if they were provided by a subsystem
> that also used to be m, which arguably is not the same as being
> explicitly disabled.  With "select" this is not a problem as the target
> symbol is also promoted to y in that case, so I wanted to preserve that
> property.
Right, but that's an argument for pushing the subsystem's default to y,
not for preventing changing the subsystem back to m afterwards.
>> Then if BAZ-features are only
>> desired for driver FOO2, BAz=m makes sense.
> In that case it would make more sense to add a config option related to
> FOO asking if BAZ features are desired for that driver (there is already
> one occurrence of that with PTP).  Or you could simply drop the "imply"
> statement from the FOO config entry.
But the desire is a property of the user, not of the driver.  If you're
willing to add CONFIG_FOO_BAZ to every combination of (driver, subsystem)
then "imply" becomes unnecessary, doesn't it?  Conversely, if you *don't*
want to have to do that, then "imply" needs to only ever deal in defaults,
not in limitations.
>> There is also the case of drivers with the ability to detect at runtime
>> whether BAZ is present, rather than making the decision at build time, but
>> I'm not sure how common that is.
> Right now that's how PTP support is done.  Drivers can optimize things
> at build time, but most of them simply cope with a NULL return from
> ptp_clock_register().  Hence the imply statement becomes a big
> configuration hint rather than some hard build dependency.
Right, so those drivers can use PTP if they're y and PTP is m, as long as
the PTP module is loaded when they probe.  But current "imply" semantics
won't allow that...

I think that Josh's suggestion (have the UI warn you if you set BAZ to m
while FOO=y) is the right approach, but I also think it should be done
now rather than at some unspecified future time.  Otherwise you forbid
potentially valid configs.

-Ed
The information contained in this message is confidential and is intended for the addressee(s) only. If you have received this message in error, please notify the sender immediately and delete the message. Unless you are an addressee (or authorized to receive for an addressee), you may not use, copy or disclose to anyone this message or any information contained in this message. The unauthorized use, disclosure, copying or alteration of this message is strictly prohibited.
