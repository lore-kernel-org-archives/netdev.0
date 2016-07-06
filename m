From: Iyappan Subramanian <isubramanian@apm.com>
Subject: Re: [PATCH v2 3/5] drivers: net: phy: Add MDIO driver
Date: Wed, 6 Jul 2016 16:44:44 -0700
Message-ID: <CAKh23FnvgWRMo=M35Mj4=a_KeUpvOoHa8stU=bSk9Y3VSRtyzQ@mail.gmail.com>
References: <1464739840-21971-1-git-send-email-isubramanian@apm.com>
 <1464739840-21971-4-git-send-email-isubramanian@apm.com> <20160601011148.GD31982@lunn.ch>
 <CAKh23FmaQy8J=f-eyfBeNndz0oT5R0icvwJ3vrw1DMJnj9uv_g@mail.gmail.com> <20160705134950.GC5230@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>, patches <patches@apm.com>,
	Matthias Brugger <matthias.bgg@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f50.google.com ([209.85.213.50]:35089 "EHLO
	mail-vk0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755788AbcGFXoq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jul 2016 19:44:46 -0400
Received: by mail-vk0-f50.google.com with SMTP id v6so326107vkb.2
        for <netdev@vger.kernel.org>; Wed, 06 Jul 2016 16:44:45 -0700 (PDT)
In-Reply-To: <20160705134950.GC5230@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

On Tue, Jul 5, 2016 at 6:49 AM, Andrew Lunn <andrew@lunn.ch> wrote:
> On Mon, Jun 06, 2016 at 10:12:35AM -0700, Iyappan Subramanian wrote:
>> Hi Andrew,
>>
>> Thanks for the review.
>>
>> On Tue, May 31, 2016 at 6:11 PM, Andrew Lunn <andrew@lunn.ch> wrote:
>> > On Tue, May 31, 2016 at 05:10:38PM -0700, Iyappan Subramanian wrote:
>> >> +static int xgene_mdio_reset(struct xgene_mdio_pdata *pdata)
>> >> +{
>> >> +     int ret;
>> >> +
>> >> +     if (pdata->mdio_id == XGENE_MDIO_RGMII) {
>> >> +             if (pdata->dev->of_node) {
>> >> +                     clk_prepare_enable(pdata->clk);
>> >> +                     clk_disable_unprepare(pdata->clk);
>> >> +                     clk_prepare_enable(pdata->clk);
>> >
>> > Hi Iyappan
>> >
>> > Is that a workaround for a hardware problem? If so, i would suggest
>> > adding a comment, to stop people submitting a patch simplifying it.
>>
>> Hardware expects this clock sequence.  I'll add comment as you suggested.
>
> What exactly does the hardware require? Is this a workaround for a bug
> in the clock generator? Or a workaround for a bug in the MDIO device?

Hardware requires a clock pulse.  There is no bug.

>
> If it is a clock generator bug, i think the fix should be in the clock
> driver. If this is bug in the MDIO device, do you need a sleep in
> there, so you actually have the clock ticking/not ticking for a time?
> Since these calls can all sleep, you have no idea how long/sort the
> clock will be enabled/disabled.
>
>       Andrew
