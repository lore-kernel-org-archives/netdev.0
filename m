From: Greg Ungerer <gerg@uclinux.org>
Subject: Re: [PATCH] net: fec: stop the "rcv is not +last, " error messages
Date: Thu, 31 Mar 2016 11:17:10 +1000
Message-ID: <56FC7A96.9070002@uclinux.org>
References: <56FB46EA.7050401@uclinux.org>
 <CAOMZO5B79aHocuqT4jgEU9gGcFYD5ZSDZh8PrGeXYAcLHW1x5Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Troy Kisky <troy.kisky@boundarydevices.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Fabio Estevam <festevam@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from icp-osb-irony-out8.external.iinet.net.au ([203.59.1.225]:20466
	"EHLO icp-osb-irony-out8.external.iinet.net.au" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750803AbcCaBR1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Mar 2016 21:17:27 -0400
In-Reply-To: <CAOMZO5B79aHocuqT4jgEU9gGcFYD5ZSDZh8PrGeXYAcLHW1x5Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Fabio,

On 31/03/16 04:37, Fabio Estevam wrote:
> Hi Greg,
> 
> On Wed, Mar 30, 2016 at 12:24 AM, Greg Ungerer <gerg@uclinux.org> wrote:
>> Hi Troy,
>>
>> Commit 55cd48c8 ('net: fec: stop the "rcv is not +last, " error
>> messages') adds a write to a register that is not present in all
>> implementations of the FEC hardware module. None of the ColdFire
>> SoC parts with the FEC module have the FTRL (0x1b0) register.
>>
>> Does this need a quirk flag to key access to this register of?
>> Or can you piggyback on the FEC_QUIRK_HAS_RACC flag?
> 
> Would the change below work on Coldfire?
> 
> --- a/drivers/net/ethernet/freescale/fec_main.c
> +++ b/drivers/net/ethernet/freescale/fec_main.c
> @@ -943,8 +943,8 @@ fec_restart(struct net_device *ndev)
>                 else
>                         val &= ~FEC_RACC_OPTIONS;
>                 writel(val, fep->hwp + FEC_RACC);
> -       }
>         writel(PKT_MAXBUF_SIZE, fep->hwp + FEC_FTRL);
> +       }
>  #endif
> 
>         /*

Yes, that fixes it. Will you carry this change?

Regards
Greg
