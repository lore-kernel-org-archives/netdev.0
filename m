From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] net: mdio-gpio: support access that may sleep
Date: Fri, 24 Apr 2015 20:42:49 +0300
Message-ID: <553A8099.5000705@cogentembedded.com>
References: <1429722414-18173-1-git-send-email-vivien.didelot@savoirfairelinux.com> <20150424.110455.2117537129018647564.davem@davemloft.net> <553A67B2.3040400@gmail.com> <553A7C73.7040002@cogentembedded.com> <553A7F28.4040109@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com
To: Florian Fainelli <f.fainelli@gmail.com>,
	David Miller <davem@davemloft.net>,
	vivien.didelot@savoirfairelinux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f175.google.com ([209.85.217.175]:36776 "EHLO
	mail-lb0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S967128AbbDXRmy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Apr 2015 13:42:54 -0400
Received: by lbbqq2 with SMTP id qq2so41883497lbb.3
        for <netdev@vger.kernel.org>; Fri, 24 Apr 2015 10:42:52 -0700 (PDT)
In-Reply-To: <553A7F28.4040109@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/24/2015 08:36 PM, Florian Fainelli wrote:

>>>>> Some systems using mdio-gpio may use gpio on message based busses,
>>>>> which
>>>>> require sleeping (e.g. gpio from an I2C I/O expander).

>>>>> Since this driver does not use IRQ handler, it is safe to use the
>>>>> _cansleep suffixed gpio accessors.

>>>>> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

>>>> Since this is down underneath the layer of an MII bus, you cannot
>>>> universally say that these routines are always called in a sleepable
>>>> context.

>>>> The PHY layer, and the driver itself above that, might call these
>>>> routines from timers, interruptes etc.

>>> The PHY library calls these routines from its state machine workqueue
>>> for that reason, or from process context (when invoked via ethtool
>>> ioctl). The only special case is phy_mac_interrupt() which is callable
>>> from interrupt context,

>>     It is not (as we have discussed recently) -- cancel_work_sync() may
>> sleep.

> True, but that does not invalidate my comment, I meant to write that
> this is the only function that you *might* potentially want to call from
> interrupt context,

    Sure, I did want that. :-)

> and yet it does not trigger low-level I/O accesses to
> the underlying MDIO bus, but instead uses the PHY library state machine
> workqueue to do that.

    That's so.

> Thanks for the reminder though, that needs fixing ;)

    Hopefully it's fixable... I had to use GPIO interrupt for AVB_PHY_INT pin 
since I didn't want to create a thread just to call phy_mac_interrupt().

> --
> Florian

WBR, Sergei
