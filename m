From: Emmanuel Grumbach <egrumbach@gmail.com>
Subject: Re: [GIT] Networking
Date: Wed, 18 May 2016 06:37:12 +0300
Message-ID: <CANUX_P3n0ZkTw0fY8wD3biu2mLzrwyX7n=bo1otw9m0bpfS07Q@mail.gmail.com>
References: <20160517.151113.367799295750703003.davem@davemloft.net>
	<CA+55aFw_JRGNo3HYP3c=3VoGw_uYBP_h2OmxOMcUGsU=L43btw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Johannes Berg <johannes.berg@intel.com>,
	Emmanuel Grumbach <emmanuel.grumbach@intel.com>,
	Kalle Valo <kvalo@codeaurora.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Intel Linux Wireless <linuxwifi@intel.com>,
	Linux Wireless List <linux-wireless@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>,
	Luca Coelho <luciano.coelho@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:34275 "EHLO
	mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751458AbcERDhO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2016 23:37:14 -0400
In-Reply-To: <CA+55aFw_JRGNo3HYP3c=3VoGw_uYBP_h2OmxOMcUGsU=L43btw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 18, 2016 at 4:00 AM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
> On Tue, May 17, 2016 at 12:11 PM, David Miller <davem@davemloft.net> wrote:
>>
>> Highlights:
>
> Lowlights:
>
>  1) the iwlwifi driver seems to be broken
>
> My laptop that uses the intel 7680 iwlwifi module no longer connects
> to the network. It fails with a "Microcode SW error detected." and
> spews out register state over and over again.

Can we have the register state and the ASSERT / NMI / whatever that
goes along with it?
This clearly means that the firmware is crashing, but I don't know why,
I copied here the lines that I need from another bug with another
device with another firmware,
but the log that we will still explain what I need:

[  800.880402] iwlwifi 0000:02:00.0: Start IWL Error Log Dump:
[  800.880406] iwlwifi 0000:02:00.0: Status: 0x00000000, count: 6
[  800.880409] iwlwifi 0000:02:00.0: Loaded firmware version: 21.311951.0
[  800.880413] iwlwifi 0000:02:00.0: 0x00000394 | ADVANCED_SYSASSERT
[  800.880416] iwlwifi 0000:02:00.0: 0x00000220 | trm_hw_status0
[  800.880419] iwlwifi 0000:02:00.0: 0x00000000 | trm_hw_status1
[  800.880422] iwlwifi 0000:02:00.0: 0x00000BD8 | branchlink2
[  800.880425] iwlwifi 0000:02:00.0: 0x00026AC4 | interruptlink1
[  800.880428] iwlwifi 0000:02:00.0: 0x00000000 | interruptlink2
[  800.880431] iwlwifi 0000:02:00.0: 0x00000001 | data1
[  800.880434] iwlwifi 0000:02:00.0: 0x02039845 | data2
[  800.880437] iwlwifi 0000:02:00.0: 0x00000056 | data3
[  800.880440] iwlwifi 0000:02:00.0: 0x8E4184A7 | beacon time
[  800.880443] iwlwifi 0000:02:00.0: 0x30E2CB41 | tsf low
[  800.880446] iwlwifi 0000:02:00.0: 0x00000027 | tsf hi
[  800.880449] iwlwifi 0000:02:00.0: 0x00000000 | time gp1
[  800.880451] iwlwifi 0000:02:00.0: 0x2F842F8A | time gp2
[  800.880454] iwlwifi 0000:02:00.0: 0x00000000 | uCode revision type
[  800.880457] iwlwifi 0000:02:00.0: 0x00000015 | uCode version major
[  800.880460] iwlwifi 0000:02:00.0: 0x0004C28F | uCode version minor
[  800.880463] iwlwifi 0000:02:00.0: 0x00000201 | hw version
[  800.880466] iwlwifi 0000:02:00.0: 0x00489008 | board version
[  800.880469] iwlwifi 0000:02:00.0: 0x0000001C | hcmd
[  800.880472] iwlwifi 0000:02:00.0: 0x24022000 | isr0
[  800.880475] iwlwifi 0000:02:00.0: 0x01000000 | isr1
[  800.880478] iwlwifi 0000:02:00.0: 0x0000580A | isr2
[  800.880481] iwlwifi 0000:02:00.0: 0x4041FCC1 | isr3
[  800.880483] iwlwifi 0000:02:00.0: 0x00000000 | isr4
[  800.880486] iwlwifi 0000:02:00.0: 0x00800110 | last cmd Id
[  800.880489] iwlwifi 0000:02:00.0: 0x00000000 | wait_event
[  800.880492] iwlwifi 0000:02:00.0: 0x000002C8 | l2p_control
[  800.880495] iwlwifi 0000:02:00.0: 0x00018030 | l2p_duration
[  800.880498] iwlwifi 0000:02:00.0: 0x000000BF | l2p_mhvalid
[  800.880501] iwlwifi 0000:02:00.0: 0x000000EF | l2p_addr_match
[  800.880503] iwlwifi 0000:02:00.0: 0x0000000D | lmpm_pmg_sel
[  800.880506] iwlwifi 0000:02:00.0: 0x30031805 | timestamp
[  800.880509] iwlwifi 0000:02:00.0: 0x0000E0F0 | flow_handler




>
> The last thing it says before falling over is:
>
>   wlp1s0: authenticate with xx:xx:xx:xx:xx:xx
>   wlp1s0: send auth to xx:xx:xx:xx:xx:xx (try 1/3)
>   wlp1s0: send auth to xx:xx:xx:xx:xx:xx (try 2/3)
>
> and then it goes all titsup.
>
> I thought that it might be because I had downloaded one of the daily
> firmware versions (it calls itself iwlwifi-7260-17.ucode, but isn't a
> real release afaik - but it has worked fien for me before), but the
> problem persists with the ver-16 ucode too, so that wasn't it.
>
> I haven't bisected it, but there is absolutely nothing odd in my hardware.
>
> I do have a 802.11ac network, which apparently not everybody does,
> judging by previous bug-reports of mine..
>
> Intel iwlwifi people: please check this out.
>
>                Linus
> --
> To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
