From: Diego Viola <diego.viola@gmail.com>
Subject: Re: [PATCH v3] net: jme: fix suspend/resume on JMC260
Date: Thu, 3 Mar 2016 00:19:16 -0300
Message-ID: <CA+ToGPH5cMTZBi_F9tBbOrPqk_Zpd0wHFt=h0CAvj_3NBOumOg@mail.gmail.com>
References: <1456239844-4109-1-git-send-email-diego.viola@gmail.com>
	<20160224.235856.242530723940439026.davem@davemloft.net>
	<20160302051405.M6687@cooldavid.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, richard.weinberger@gmail.com,
	pavel@ucw.cz, rjw@rjwysocki.net, valdis.kletnieks@vt.edu
To: Guo-Fu Tseng <cooldavid@cooldavid.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:35205 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755902AbcCCDTS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2016 22:19:18 -0500
In-Reply-To: <20160302051405.M6687@cooldavid.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 2, 2016 at 2:14 AM, Guo-Fu Tseng <cooldavid@cooldavid.org> wrote:
> On Wed, 24 Feb 2016 23:58:56 -0500 (EST), David Miller wrote
>> From: Diego Viola <diego.viola@gmail.com>
>> Date: Tue, 23 Feb 2016 12:04:04 -0300
>>
>> > The JMC260 network card fails to suspend/resume because the call to
>> > jme_start_irq() was too early, moving the call to jme_start_irq() after
>> > the call to jme_reset_link() makes it work.
>> >
>> > Prior this change suspend/resume would fail unless /sys/power/pm_async=0
>> > was explicitly specified.
>> >
>> > Relevant bug report: https://bugzilla.kernel.org/show_bug.cgi?id=112351
>> >
>> > Signed-off-by: Diego Viola <diego.viola@gmail.com>
>>
>> Applied and queued up for -stable, thanks.
>
> Just reviewed it, it should have no side effect.
>
> Thanks David, Diego.
>
> Guo-Fu Tseng
>

Hi all,

I'm having another issue with jme and I'm not sure if it's related to
the same issue with suspend/resume, but the problem now is WoL.

Let me try to describe the problem a bit:

I put my machine to sleep in S3 and I send WoL packets from a laptop,
and the machine doesn't wake up at all, I tried inspecting packets
with tcpdump and nothing shows up in the tcpdump output.

When the machine is in working state, and I send WoL packets and I
initiate a S3, it refuses to go in sleep mode.

I tried the same in Windows (waking up from S3 via WoL) and it works there.

Does anyone have any ideas what the problem can be? I talked with Guo
and he suspects the problem is motherboard failure, I also think the
issue can be a BIOS bug since I hear so many horror stories about AMI
BIOS issues with Linux.

But it's still a mystery to me given all these conditions I mentioned.

Diego
