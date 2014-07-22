From: Sonic Zhang <sonic.adi@gmail.com>
Subject: Re: [PATCH v5] bfin_mac: convert bfin Ethernet driver to NAPI framework
Date: Tue, 22 Jul 2014 13:19:53 +0800
Message-ID: <CAJxxZ0PjcCpOb0DXF1JNz+tTWQPue0RS65OcxqZ_sJQGxUH67Q@mail.gmail.com>
References: <1405504302-21344-1-git-send-email-sonic.adi@gmail.com>
	<1405516649.10255.59.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140716.140301.896018835447121717.davem@davemloft.net>
	<CAJxxZ0OybvReRHvRuL84N=25T6cRG8k1j_gXLcu7U6jHvSZ5Tw@mail.gmail.com>
	<20140717222906.GA23125@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Varka Bhadram <varkabhadram@gmail.com>,
	adi-buildroot-devel@lists.sourceforge.net,
	"Zhang, Sonic" <sonic.zhang@analog.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f41.google.com ([209.85.219.41]:35834 "EHLO
	mail-oa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750742AbaGVF1C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2014 01:27:02 -0400
Received: by mail-oa0-f41.google.com with SMTP id j17so9041186oag.0
        for <netdev@vger.kernel.org>; Mon, 21 Jul 2014 22:27:01 -0700 (PDT)
In-Reply-To: <20140717222906.GA23125@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Francois,

On Fri, Jul 18, 2014 at 6:29 AM, Francois Romieu <romieu@fr.zoreil.com> wrote:
> Sonic Zhang <sonic.adi@gmail.com> :
>> On Thu, Jul 17, 2014 at 5:03 AM, David Miller <davem@davemloft.net> wrote:
> [...]
>> > Please mimick what other drivers do rather than trying to do things in
>> > a special way unique to your driver.
>>
>> Driver realtek/8139cp.c does things in the same way as the bfin_mac
>> NAPI code.
>
> It wasn't your lucky day.
>
>> In net_poll loop, if napi_complete() is called, the EMAC IRQ is
>> enabled more times than the it is disabled. This is not a problem to
>> drivers which don't call enable_irq()/disable_irq_nosync(). But, the
>> IRQ enabling and disabling operations have to be balanced in the
>> bfin_mac driver via __napi_complete() to avoid the kernel warning.
>
> Thanks for the explanation.
>
> In order to use plain napi_complete, may I suggest keeping a mask of
> bfin_mac_interrupt disabled irq in the device private area then
> enable_irq relevant one - if any - in bfin_mac_poll ?
>
> It should keep things balanced.

This is fine to me.

Thanks,

Sonic Zhang
