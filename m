From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH v2 11/14] bnx2x: Update bnx2x to use new vlan accleration.
Date: Tue, 26 Oct 2010 10:57:38 -0700
Message-ID: <AANLkTimgKN3ddBR=PjB9PXgwDmOfDESaVNFp33GR6E+g@mail.gmail.com>
References: <1287618974-4714-1-git-send-email-jesse@nicira.com>
	<1287618974-4714-12-git-send-email-jesse@nicira.com>
	<8628FE4E7912BF47A96AE7DD7BAC0AADDDEE429135@SJEXCHCCR02.corp.ad.broadcom.com>
	<8628FE4E7912BF47A96AE7DD7BAC0AADDDEE429137@SJEXCHCCR02.corp.ad.broadcom.com>
	<8628FE4E7912BF47A96AE7DD7BAC0AADDDEE42913C@SJEXCHCCR02.corp.ad.broadcom.com>
	<AANLkTinudtxjGAEcc9cLjn+7Y7kqcaQXMW_5SRoNe5QU@mail.gmail.com>
	<8628FE4E7912BF47A96AE7DD7BAC0AADDDEE6B11FD@SJEXCHCCR02.corp.ad.broadcom.com>
	<8628FE4E7912BF47A96AE7DD7BAC0AADDDEE6B1203@SJEXCHCCR02.corp.ad.broadcom.com>
	<AANLkTimjTZU_GWgBNADgAtw7ViztZD-cdhHLQYremz2A@mail.gmail.com>
	<8628FE4E7912BF47A96AE7DD7BAC0AADDDEE6B1428@SJEXCHCCR02.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Hao Zheng <hzheng@nicira.com>,
	Eilon Greenstein <eilong@broadcom.com>
To: Vladislav Zolotarov <vladz@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:36032 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752527Ab0JZR5k convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Oct 2010 13:57:40 -0400
Received: by ewy7 with SMTP id 7so5630123ewy.19
        for <netdev@vger.kernel.org>; Tue, 26 Oct 2010 10:57:38 -0700 (PDT)
In-Reply-To: <8628FE4E7912BF47A96AE7DD7BAC0AADDDEE6B1428@SJEXCHCCR02.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 26, 2010 at 2:14 AM, Vladislav Zolotarov <vladz@broadcom.co=
m> wrote:
>>
>> Even though the fix prevents the panic, I'm still a little concerned
>> that you ran into it at all when vlan stripping was disabled. =A0Tha=
t
>> function should only be called when a tag was received by the card.
>> Is it possible that __vlan_hwaccel_put_tag is being called even in
>> cases when no tag was stripped?
>
> Correct, and that's because u've patched the driver to put it the
> following way:
>
> if (le16_to_cpu(cqe->fast_path_cqe.pars_flags.flags) &
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 PARSING_FLAGS_VLAN)
> =A0 =A0 =A0 =A0__vlan_hwaccel_put_tag(skb, le16_to_cpu(cqe->fast_path=
_cqe.vlan_tag));
>
> The condition above will be TRUE regardless VLAN stripping is enabled=
 or
> disabled as the parsing flags come from our PARSER HW block and simpl=
y
> indicates whether this frame has a VLAN header or not. When I disable=
d a VLAN
> stripping I should have fixed this lines too but I think I didn't... =
;)
>
>> Maybe we made a mistake when converting the driver?
>
> Since the driver always configures the VLAN stripping now, regardless=
 the kernel
> configuration, I think your patch was just fine. ;)

Great.  Thanks for the explanation and confirmation.
