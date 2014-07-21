From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next v6 04/11] net: Export xmit_recursion
Date: Mon, 21 Jul 2014 10:01:52 -0700
Message-ID: <CALnjE+r7BaX1C1X5=9mz4LUQhZZ9B13prukwh0x5_vBsesZYEA@mail.gmail.com>
References: <1405923435-1971-1-git-send-email-pshelar@nicira.com>
	<063D6719AE5E284EB5DD2968C1650D6D17279E9B@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog126.obsmtp.com ([74.125.149.155]:54160 "HELO
	na3sys009aog126.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S932740AbaGURB4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2014 13:01:56 -0400
Received: by mail-vc0-f175.google.com with SMTP id hu12so12423260vcb.6
        for <netdev@vger.kernel.org>; Mon, 21 Jul 2014 10:01:55 -0700 (PDT)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D17279E9B@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 21, 2014 at 1:52 AM, David Laight <David.Laight@aculab.com> wrote:
> From: Pravin B Shelar
>> Next patch adds re-circulation action to OVS. This is recursive
>> action needs to be limited to safe number recursions to
>> avoid overflowing kernel stack space.  This patch export
>> xmit_recursion so that OVS can increment and check the value
>> before executing recirc action.
> ...
>> +#define NET_RECURSION_LIMIT 10
>
> I'm not entirely sure that any amount of recursion is a good idea
> inside the kernel.
> If the nested call frame is small enough so that your 10 nestings
> are valid it must also be reasonably easy to arrange for the code
> to be converted to a loop.
>
> Remember that the highest stack use is likely to be inside some
> error path (probably inside printk) so any experiments that seem
> to imply that that stack use is ok are doomed.
>
> Static analysis is possible (indirect calls make it tricky) provided
> there is no recursion.
> I did some static stack use analysis for an embedded system many
> years ago. It showed that we needed much larger stacks that we'd
> allowed for.

I am using same recursion counter as networking stack does. Recursion
in OVS has lesser cost compared to recursion in networking stack, So
it is conservative to use same counter to track recursion in OVS as
networking stack recursion.
