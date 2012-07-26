From: Xufeng Zhang <xufengzhang.main@gmail.com>
Subject: Re: [PATCH] sctp: Make "Invalid Stream Identifier" ERROR follows SACK
 when bundling
Date: Thu, 26 Jul 2012 10:50:02 +0800
Message-ID: <CA+=dFziK09TVcK29x1SLg+JanOj6o__bJKf8yohw6dTYCUCF5A@mail.gmail.com>
References: <1342677450-21810-1-git-send-email-xufengzhang.main@gmail.com>
	<500CDE35.6000009@windriver.com>
	<42fcd21f-68bd-4dc7-8460-0cb968eb512e@email.android.com>
	<500E1057.3020509@windriver.com>
	<75bdd73e-1c47-4fd6-bc29-5b86ee6da69a@email.android.com>
	<CA+=dFzg=Bpsv5bMzECoAXYVcbD95eYy6xDAzL6fwiHrunfq-tg@mail.gmail.com>
	<e7f8a685-9635-4aa9-bd67-1044e0720b29@email.android.com>
	<CA+=dFzifKwbiXmw=pu0+rWmz72+4jsbv6bXOBHyL0LmxaL9byg@mail.gmail.com>
	<CA+=dFzgXq3Sx-Ny+6oDZ3BEdsMQCgswNEVPVnhmhedHFvazzWw@mail.gmail.com>
	<50100A29.8010705@gmail.com>
	<CA+=dFzj11c9K0TS0T7D1aBVz+ppdFK91ZzBbevLV23FrWJNzmw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Neil Horman <nhorman@tuxdriver.com>,
	xufeng zhang <xufeng.zhang@windriver.com>, sri@us.ibm.com,
	davem@davemloft.net, linux-sctp@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f46.google.com ([209.85.212.46]:64449 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752448Ab2GZCuE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jul 2012 22:50:04 -0400
In-Reply-To: <CA+=dFzj11c9K0TS0T7D1aBVz+ppdFK91ZzBbevLV23FrWJNzmw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/26/12, Xufeng Zhang <xufengzhang.main@gmail.com> wrote:
> On 7/25/12, Vlad Yasevich <vyasevich@gmail.com> wrote:
>>> And after take a moment to look into the relative codes, I think we
>>> can implement it
>>> by below way:
>>> 1). Add a flag(isi_err_needed) in the embedded struct peer of struct
>>> struct sctp_association
>>> just like sack_needed flag.
>>> 2). When "invalid stream identifier" ERROR happens in sctp_eat_data()
>>> function, we just
>>> set isi_err_needed flag and don't create ERROR chunk and also don't
>>> insert SCTP_CMD_REPLY command.
>>> 3). In sctp_gen_sack() function, we create ERROR chunk and also insert
>>> SCTP_CMD_REPLY command if isi_err_needed flag is set.
>>>
>>> Is this way proper?
>>>
>>
>> So, I looked at the code, and it looks very simple to do.  We already
>> return a specific status from sctp_eat_data() when the error was
>> generated.  All you have to do is take the code that generates the error
>> and adds it to the command list and give it its own small function that
>> you can then call if SCTP_IERROR_BAD_STREAM error was returned.
>
> No, it will still has the same problem by just doing this.
> SCTP_CMD_GEN_SACK command actually don't enqueue SACK to outqueue,
> sctp_gen_sack() do this things when processing SCTP_CMD_GEN_SACK command
> in sctp_cmd_interpreter().
> So it's not enough if we just insert SCTP_ERROR_INV_STRM command after
> sctp_eat_data() return SCTP_IERROR_BAD_STREAM in sctp_sf_eat_data_6_2().

Yes, I just tried this way, SACK is still bundled after ERROR chunk.
But I think my above method is also not fine if there are multiple
error DATA chunks
bundled in a packet.
Really awesome!



Thanks,
Xufeng Zhang

>
>
>
> Thanks,
> Xufeng Zhang
>
>>
>> -vlad
>>
>>>
>>> Thanks,
>>> Xufeng Zhang
>>>>
>>>>
>>>>
>>>> Thanks,
>>>> Xufeng Zhang
>>>>>
>>>>> -vlad
>>>>>>
>>>>>> Thanks,
>>>>>> Xufeng Zhang
>>>>>>>
>>>>>>> -vlad
>>>>>
>>>>>
>>>>> --
>>>>> Sent from my Android phone with SkitMail. Please excuse my brevity.
>>>>>
>>>>
>>
>>
>>
>
