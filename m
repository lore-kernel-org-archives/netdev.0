From: Marian Corcodel <corcodel.marian@gmail.com>
Subject: Re: [PATCH net-next] r8169:Set RxConfig on same func. with TxConfig
Date: Wed, 19 Aug 2015 08:39:03 +0300
Message-ID: <CAGg4U=FDptTDEuw2r266o9KWun9UaEEZUt9XRnxRgnxv=foXhg@mail.gmail.com>
References: <1439925021-5772-1-git-send-email-corcodel.marian@gmail.com>
	<1439928257.6610.4.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:37220 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751016AbbHSFjE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2015 01:39:04 -0400
Received: by igui7 with SMTP id i7so96749398igu.0
        for <netdev@vger.kernel.org>; Tue, 18 Aug 2015 22:39:03 -0700 (PDT)
In-Reply-To: <1439928257.6610.4.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It s not mandatory to accept
these patches, if you wish
to apply good if you not ,not problem.

2015-08-18 23:04 GMT+03:00, Eric Dumazet <eric.dumazet@gmail.com>:
> On Tue, 2015-08-18 at 22:10 +0300, Corcodel Marian wrote:
>>  Add set DMA burst size and  Rx FIFO threshold on RxConfig
>>   register to function rtl_set_rx_tx_config_register.
>>
>>
>> Signed-off-by: Corcodel Marian <corcodel.marian@gmail.com>
>>
>> diff --git a/drivers/net/ethernet/realtek/r8169.c
>> b/drivers/net/ethernet/realtek/r8169.c
>> index 6d16de3..c3c908c 100644
>> --- a/drivers/net/ethernet/realtek/r8169.c
>> +++ b/drivers/net/ethernet/realtek/r8169.c
>> @@ -5183,6 +5183,7 @@ static void rtl_set_rx_tx_config_registers(str=
uct
>> rtl8169_private *tp)
>>  	/* Set DMA burst size and Interframe Gap Time */
>>  	RTL_W32(TxConfig, (TX_DMA_BURST << TxDMAShift) |
>>                  (InterFrameGap << TxInterFrameGapShift) |
>> InterFrameGap2);
>> +	RTL_W32(RxConfig, RX_FIFO_THRESHOLD | RX_DMA_BURST);
>>  }
>>
>>  static void rtl_hw_start(struct net_device *dev)
>
> This does not even compile. This is insane.
>
>
>
>   CC [M]  drivers/net/ethernet/realtek/r8169.o
> drivers/net/ethernet/realtek/r8169.c: In function
> =E2=80=98rtl_set_rx_tx_config_registers=E2=80=99:
> drivers/net/ethernet/realtek/r8169.c:5186:20: error: =E2=80=98RX_FIFO=
_THRESHOLD=E2=80=99
> undeclared (first use in this function)
>   RTL_W32(RxConfig, RX_FIFO_THRESHOLD | RX_DMA_BURST);
>                     ^
> drivers/net/ethernet/realtek/r8169.c:104:38: note: in definition of
> macro =E2=80=98RTL_W32=E2=80=99
>  #define RTL_W32(reg, val32) writel ((val32), ioaddr + (reg))
>                                       ^
> drivers/net/ethernet/realtek/r8169.c:5186:20: note: each undeclared
> identifier is reported only once for each function it appears in
>   RTL_W32(RxConfig, RX_FIFO_THRESHOLD | RX_DMA_BURST);
>                     ^
> drivers/net/ethernet/realtek/r8169.c:104:38: note: in definition of
> macro =E2=80=98RTL_W32=E2=80=99
>  #define RTL_W32(reg, val32) writel ((val32), ioaddr + (reg))
>                                       ^
> make[1]: *** [drivers/net/ethernet/realtek/r8169.o] Error 1
> make: *** [drivers/net/ethernet/realtek/r8169.o] Error 2
>
>
>
