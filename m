From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH v2 11/14] bnx2x: Update bnx2x to use new vlan accleration.
Date: Mon, 25 Oct 2010 17:29:39 -0700
Message-ID: <AANLkTimjTZU_GWgBNADgAtw7ViztZD-cdhHLQYremz2A@mail.gmail.com>
References: <1287618974-4714-1-git-send-email-jesse@nicira.com>
	<1287618974-4714-12-git-send-email-jesse@nicira.com>
	<8628FE4E7912BF47A96AE7DD7BAC0AADDDEE429135@SJEXCHCCR02.corp.ad.broadcom.com>
	<8628FE4E7912BF47A96AE7DD7BAC0AADDDEE429137@SJEXCHCCR02.corp.ad.broadcom.com>
	<8628FE4E7912BF47A96AE7DD7BAC0AADDDEE42913C@SJEXCHCCR02.corp.ad.broadcom.com>
	<AANLkTinudtxjGAEcc9cLjn+7Y7kqcaQXMW_5SRoNe5QU@mail.gmail.com>
	<8628FE4E7912BF47A96AE7DD7BAC0AADDDEE6B11FD@SJEXCHCCR02.corp.ad.broadcom.com>
	<8628FE4E7912BF47A96AE7DD7BAC0AADDDEE6B1203@SJEXCHCCR02.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Hao Zheng <hzheng@nicira.com>,
	Eilon Greenstein <eilong@broadcom.com>
To: Vladislav Zolotarov <vladz@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:32991 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753183Ab0JZA3l convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Oct 2010 20:29:41 -0400
Received: by wwb34 with SMTP id 34so105910wwb.1
        for <netdev@vger.kernel.org>; Mon, 25 Oct 2010 17:29:40 -0700 (PDT)
In-Reply-To: <8628FE4E7912BF47A96AE7DD7BAC0AADDDEE6B1203@SJEXCHCCR02.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 24, 2010 at 3:11 AM, Vladislav Zolotarov <vladz@broadcom.co=
m> wrote:
>
>
>> -----Original Message-----
>> From: netdev-owner@vger.kernel.org [mailto:netdev-
>> owner@vger.kernel.org] On Behalf Of Vladislav Zolotarov
>> Sent: Sunday, October 24, 2010 11:22 AM
>> To: Jesse Gross
>> Cc: David Miller; netdev@vger.kernel.org; Hao Zheng; Eilon Greenstei=
n
>> Subject: RE: [PATCH v2 11/14] bnx2x: Update bnx2x to use new vlan
>> accleration.
>>
>>
>>
>> > >
>> > > We hit the same BUG() both when VLAN stripping is disabled.
>> >
>> > This one surprises me because that function shouldn't get called a=
t
>> > all when VLAN stripping is disabled. =A0Are you sure that it is
>> > disabled? =A0From my reading of the bnx2x driver it seems like it =
is
>> > always enabled.
>>
>> I tried to check all possibilities and to check at which level the
>> problem is,
>> so I patched the bnx2x not to do the stripping and recompiled it wit=
h
>> the
>> kernel having CONFIG_VLAN_8021Q disabled. Then I saw the (same) BUG(=
)
>> message
>> again. It seems to me that your patch series were meant to remove th=
e
>> handling of this configuration (CONFIG_VLAN_8021Q) from the L2 drive=
rs
>> as well, isn't it? This means that the same VLAN flows, both
>> accelerated and none
>> accelerated should be "active" both when this configuration is prese=
nt
>> and
>> when it's not... Do I get it right?
>>
>> Thanks,
>> vlad
>
> Jesse, from the fix u posted I conclude that the answer on the above =
questions is
> obviously "yes"... ;)

Yes, that's right.

>
> I first answered your question and only then looked at the "fixing"
> thread, my apologies... ;)

Even though the fix prevents the panic, I'm still a little concerned
that you ran into it at all when vlan stripping was disabled.  That
function should only be called when a tag was received by the card.
Is it possible that __vlan_hwaccel_put_tag is being called even in
cases when no tag was stripped?  Maybe we made a mistake when
converting the driver?
