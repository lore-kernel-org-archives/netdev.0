From: <Ronnie.Kunin@microchip.com>
Subject: RE: [PATCH 0/2] lan78xx: Remove trailing underscores from macros
Date: Wed, 7 Sep 2016 02:00:07 +0000
Message-ID: <CB1A8EE47AAD7B4897132E685E5108C551F87491@CHN-SV-EXMX02.mchp-main.com>
References: <cover.1473202982.git.joe@perches.com>
         <9235D6609DB808459E95D78E17F2E43D40910FF9@CHN-SV-EXMX02.mchp-main.com>,<1473211122.29864.1.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <f.fainelli@gmail.com>, <UNGLinuxDriver@microchip.com>,
        <linux-kernel@vger.kernel.org>
To: <joe@perches.com>, <Woojung.Huh@microchip.com>,
        <netdev@vger.kernel.org>, <linux-usb@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpout.microchip.com ([198.175.253.82]:33285 "EHLO
        email.microchip.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1755437AbcIGCAK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Sep 2016 22:00:10 -0400
In-Reply-To: <1473211122.29864.1.camel@perches.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Microchip's internal convention is for register (offset) definitions to be capitalized (i.e.: MY_REGISTER). Our convention for bits (position) definitions within a register is to carry as a prefix the name of the register and suffix it with the bit name and adding a trailing underscore (i.e. MY_REGISTER_MY_BIT_). The trailing underscore is what easily lets us distinguish a bit from a register definition when reading code. We have been using this convention for many years and has worked very well for us across all projects (by now hundreds).

>Is there anything other than a one-time cost
>to apply these?  Is the same code used for
>other platforms?
Yes, a single header file with the definition of registers and bits is shared (either as a standalone file or with its contents pasted into a native environment "carrier" header file) across all drivers (and other non driver software projects as well) for the same device. So a change like this indeed has a high cost for Microchip and we'd rather not do this unless it is an absolutely mandated requirement. 

Thanks,
Ronnie
________________________________________
From: Joe Perches [joe@perches.com]
Sent: Tuesday, September 06, 2016 9:18 PM
To: Woojung Huh - C21699; netdev@vger.kernel.org; linux-usb@vger.kernel.org
Cc: f.fainelli@gmail.com; UNGLinuxDriver; linux-kernel@vger.kernel.org
Subject: Re: [PATCH 0/2] lan78xx: Remove trailing underscores from macros

On Tue, 2016-09-06 at 23:19 +0000, Woojung.Huh@microchip.com wrote:
> > Joe Perches (2):
> >   lan78xx: Remove locally defined trailing underscores from defines and uses
> >   microchipphy.h and uses: Remove trailing underscores from defines and
> > uses
> >
> >  drivers/net/phy/microchip.c  |    4 +-
> >  drivers/net/usb/lan78xx.c    |  368 +++++++--------
> >  drivers/net/usb/lan78xx.h    | 1068 +++++++++++++++++++++-----------------
> > ----
> >  include/linux/microchipphy.h |   72 +--
> >  4 files changed, 756 insertions(+), 756 deletions(-)
>
>
> Because there is no specific rule how to name defines, I'm not sure it is worth to change 1000+ lines.
> It may be better to set guideline for new submissions.
>
> Welcome any comments.

Generally, more conforming to norms is better.
These FOO_ uses are non-conforming.

Is there anything other than a one-time cost
to apply these?  Is the same code used for
other platforms?
