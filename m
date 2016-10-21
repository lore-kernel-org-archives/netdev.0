From: Henri Roosen <henri.roosen@ginzinger.com>
Subject: Re: commit-3ac72b7b63d5 breaks networking on iMX28
Date: Fri, 21 Oct 2016 13:09:39 +0200
Message-ID: <bab803d5-b35b-da82-63f2-a5932f5a2e7e@ginzinger.com>
References: <bc6aa851-3f52-2274-47dc-4933662648a1@ginzinger.com>
 <CAOMZO5ADSSUkTwi3WDHHGX-i-Jm+YbrVzES0BDtGsR1kFTxO+Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 8BIT
Cc: Eric Nelson <eric@nelint.com>, Fugang Duan <fugang.duan@nxp.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Fabio Estevam <festevam@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.ginzinger.com ([31.193.165.229]:49605 "EHLO
        mail.ginzinger.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932199AbcJULJo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Oct 2016 07:09:44 -0400
In-Reply-To: <CAOMZO5ADSSUkTwi3WDHHGX-i-Jm+YbrVzES0BDtGsR1kFTxO+Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Fabio,

On 10/21/2016 12:55 PM, Fabio Estevam wrote:
> Hi Henri,
>
> 2016-10-21 7:19 GMT-02:00 Henri Roosen <henri.roosen@ginzinger.com>:
>> Hi,
>>
>> Unfortunately commit-3ac72b7b63d5 "net: fec: align IP header in
>> hardware" breaks networking on an iMX28 system.
>>
>> The commit seems valid for iMX6, where it is tested okay and solves the
>> unaligned accesses.
>>
>> On iMX28 I still see unaligned accesses and networking is broken. Can
>> anyone confirm this?
>
> Does this fix the problem?

Yes, this fixes the problem.
Note: only tested on iMX28.

Thanks,
Henri
>
> diff --git a/drivers/net/ethernet/freescale/fec_main.c
> b/drivers/net/ethernet/freescale/fec_main.c
> index 4ce8179..d1cefe1 100644
> --- a/drivers/net/ethernet/freescale/fec_main.c
> +++ b/drivers/net/ethernet/freescale/fec_main.c
> @@ -1430,14 +1430,15 @@ fec_enet_rx_queue(struct net_device *ndev, int
> budget, u16 queue_id)
>                 skb_put(skb, pkt_len - 4);
>                 data = skb->data;
>
> +               if (!is_copybreak && need_swap)
> +                       swap_buffer(data, pkt_len);
> +
> +
>  #if !defined(CONFIG_M5272)
>                 if (fep->quirks & FEC_QUIRK_HAS_RACC)
>                         data = skb_pull_inline(skb, 2);
>  #endif
>
> -               if (!is_copybreak && need_swap)
> -                       swap_buffer(data, pkt_len);
> -
>                 /* Extract the enhanced buffer descriptor */
>                 ebdp = NULL;
>                 if (fep->bufdesc_ex)
>

________________________________

Ginzinger electronic systems GmbH
Gewerbegebiet Pirath 16
4952 Weng im Innkreis
www.ginzinger.com

Firmenbuchnummer: FN 364958d
Firmenbuchgericht: Ried im Innkreis
UID-Nr.: ATU66521089


________________________________

Kommende Events:

08.-11. November 2016: Besuchen Sie uns auf der electronica in München -> Halle B1 Stand 538
16. November 2016: Nachmittagsseminar mit unserem Partner Irlbacher zum Thema „Glas als innovatives Material für moderne HMI’s“
17. November 2016: Juristisches Seminar in Linz: Einsatz von Open Source-Software in der Industrie
06. Dezember 2016: Nachmittagsseminar mit unserem Partner sequality software engineering zum Thema Usability

>> Weitere Informationen zu diesen Veranstaltungen und Neuigkeiten aus der Elektronikbranche finden Sie auf www.ginzinger.com/techtalk
