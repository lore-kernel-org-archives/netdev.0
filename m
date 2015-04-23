From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: NAPI: Polling function requesting extra calls - difference
 between 3.18.11 and 4.0.0
Date: Thu, 23 Apr 2015 20:35:37 +0200
Message-ID: <CACna6rxTknPVda1NN020iepeoPDr+CHu0sTrmS3SfUW7Xa_C0g@mail.gmail.com>
References: <CACna6rzMMUA_MQemYyP93+TjP4aocL1WaYQUJFwQm3+DLNAefg@mail.gmail.com>
	<1429813732.22254.78.camel@edumazet-glaptop2.roam.corp.google.com>
	<1429814038.22254.80.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Network Development <netdev@vger.kernel.org>,
	Felix Fietkau <nbd@openwrt.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f176.google.com ([209.85.223.176]:34185 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030547AbbDWSfh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2015 14:35:37 -0400
Received: by iedfl3 with SMTP id fl3so75913427ied.1
        for <netdev@vger.kernel.org>; Thu, 23 Apr 2015 11:35:37 -0700 (PDT)
In-Reply-To: <1429814038.22254.80.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 23 April 2015 at 20:33, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2015-04-23 at 11:28 -0700, Eric Dumazet wrote:
>> On Thu, 2015-04-23 at 20:18 +0200, Rafa=C5=82 Mi=C5=82ecki wrote:
>>
>> >
>> > Can you help us with this, please? Does bgmac use NAPI incorrectly=
?
>> > Were there some important changes in 3.19 or 4.0?
>> >
>>
>> Right they were important changes in NAPI indeed :
>>
>> 3b47d30396ba net: gro: add a per device gro flush timer
>> d75b1ade567f net: less interrupt masking in NAPI
>> bc9ad166e38a net: introduce napi_schedule_irqoff()
>>
>> This requested some fixes in various drivers :
>>
>> commit f31ec95fa19e07a8beebcc0297284f23aa57967e
>> commit 24e579c8898aa641ede3149234906982290934e5
>> commit 6088beef3f7517717bd21d90b379714dd0837079
>> commit f104fedc0da126abe93dd0f4a9fa13e5133bf9df
>> commit 7a05dc64e2e4c611d89007b125b20c0d2a4d31a5
>> commit 001ce546bb537bb5b7821f05633556a0c9787e32
>> commit 3079c652141f9d6377417a7e8fd650c9948df65e
>> commit 8acdf999accfd95093db17f33a58429a38782060
>> commit 6a6dc08ff6395f58be3ee568cb970ea956f16819
>>
>
> It looks like following fix is needed :
>
> diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethe=
rnet/broadcom/bgmac.c
> index de77d3a74abc..21e3c38c7c75 100644
> --- a/drivers/net/ethernet/broadcom/bgmac.c
> +++ b/drivers/net/ethernet/broadcom/bgmac.c
> @@ -1260,7 +1260,7 @@ static int bgmac_poll(struct napi_struct *napi,=
 int weight)
>
>         /* Poll again if more events arrived in the meantime */
>         if (bgmac_read(bgmac, BGMAC_INT_STATUS) & (BGMAC_IS_TX0 | BGM=
AC_IS_RX))
> -               return handled;
> +               return weight;
>
>         if (handled < weight) {
>                 napi_complete(napi);
>
>

Yeah, I'm flashing my device with the same patch applied right now :)


--=20
Rafa=C5=82
