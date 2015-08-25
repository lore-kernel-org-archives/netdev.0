From: Marian Corcodel <corcodel.marian@gmail.com>
Subject: Re: [PATCH, net-next] r8169: On RTL 8101 series bit SYSErr is reserved.
Date: Tue, 25 Aug 2015 07:44:42 +0300
Message-ID: <CAGg4U=GDtq+dfhs65Pg798XWY3uE86V3RS8TNnDd_ud3m5ywRQ@mail.gmail.com>
References: <1440439973-7400-1-git-send-email-corcodel.marian@gmail.com>
	<20150824.113818.620937362100781821.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:33776 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751003AbbHYEon (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 00:44:43 -0400
Received: by igfj19 with SMTP id j19so3174914igf.0
        for <netdev@vger.kernel.org>; Mon, 24 Aug 2015 21:44:42 -0700 (PDT)
In-Reply-To: <20150824.113818.620937362100781821.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

May be entire program must
rewritten due multiple errors.

2015-08-24 21:38 GMT+03:00, David Miller <davem@davemloft.net>:
> From: Corcodel Marian <corcodel.marian@gmail.com>
> Date: Mon, 24 Aug 2015 21:12:53 +0300
>
>> diff --git a/drivers/net/ethernet/realtek/r8169.c
>> b/drivers/net/ethernet/realtek/r8169.c
>> index 5693e65..32d2072 100644
>> --- a/drivers/net/ethernet/realtek/r8169.c
>> +++ b/drivers/net/ethernet/realtek/r8169.c
>> @@ -8256,6 +8256,14 @@ static int rtl_init_one(struct pci_dev *pdev, const
>> struct pci_device_id *ent)
>>  	RTL_W8(Config1, RTL_R8(Config1) | PMEnable);
>>  	RTL_W8(Config5, RTL_R8(Config5) & (BWF | MWF | UWF | LanWake |
>> PMEStatus));*/
>>  	switch (tp->mac_version) {
>> +	case RTL_GIGA_MAC_VER_07:
>> +	case RTL_GIGA_MAC_VER_08:
>> +	case RTL_GIGA_MAC_VER_09:
>> +	case RTL_GIGA_MAC_VER_10:
>> +	case RTL_GIGA_MAC_VER_13:
>> +	case RTL_GIGA_MAC_VER_16:
>> +		pci_write_config_word(pdev, PCI_COMMAND, ~PCI_COMMAND_SERR);
>
> You're writing all sorts of bits you definitely don't want to set here.
>
> Furthermore, there is no need to clear a bit that shouldn't be set
> in the first place.
>
> Your patches are really full of major errors, and unsuitable for
> upstream.
>
> Yes, all of them.
>
> So please stop posting your r8169 changes here, because if you don't
> care if your patches get included or not, then you should not be
> posting them here.  This isn't a place to just dump ramdom patches,
> sorry.
>
