From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] qed: add missing header dependencies
Date: Wed, 07 Sep 2016 14:52:56 +0200
Message-ID: <5820324.xrfiu7KHci@wuerfel>
References: <1473246420-1035-1-git-send-email-baoyou.xie@linaro.org> <4989831.9c6WyUak3s@wuerfel> <DM5PR11MB17236A48767FEFB5C59426A297F80@DM5PR11MB1723.namprd11.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Baoyou Xie <baoyou.xie@linaro.org>,
        netdev <netdev@vger.kernel.org>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        "xie.baoyou@zte.com.cn" <xie.baoyou@zte.com.cn>,
        Ariel Elior <Ariel.Elior@qlogic.com>
To: Yuval Mintz <Yuval.Mintz@qlogic.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <DM5PR11MB17236A48767FEFB5C59426A297F80@DM5PR11MB1723.namprd11.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday, September 7, 2016 12:31:03 PM CEST Yuval Mintz wrote:
> > > While I obviously have no strong objection for including
> > > qed_selftest.h from qed_selftest.c, I'm not sure I understand which C
> > > standard dictates this requirement.
> > > Why should a function definition [not call] be preceded by a prototype?
> > 
> > - When a function is defined in one file and used in another, you want
> >   both files to include the same header that has the declaration to
> >   ensure that the types are identical. There are cases where the
> >   prototype is changed after the fact in an incompatible way, causing
> >   silent data corruption on some configurations but maybe not on others.
> 
> O.k., motivation is clear.
> But this really isn't enforced by the ansi-c standard, right?

No, ansi-c doesn't enforce this, and even the regular kernel build
flags don't enable the warning in question, we only get it when
either building with "make C=1" using sparse, or "make W=1" to
enable extra warnings from gcc.

The warning is however really useful, and I hope that we go through
all drivers in the kernel and eliminate these warnings in order
to turn them on by default for all drivers.

> Acked-by: Yuval Mintz <Yuval.Mintz@qlogic.com>

Thanks,

	Arnd
