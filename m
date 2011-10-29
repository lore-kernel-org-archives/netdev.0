From: "Arend van Spriel" <arend@broadcom.com>
Subject: Re: [PATCH 2/5] drivers/net/wireless/brcm80211/brcmsmac/dma.c:
 eliminate a null pointer dereference
Date: Sat, 29 Oct 2011 11:28:55 +0200
Message-ID: <4EABC757.7080505@broadcom.com>
References: <1319846297-2985-2-git-send-email-julia@diku.dk>
 <4EAB6495.40707@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Julia Lawall" <julia@diku.dk>,
	"John W. Linville" <linville@tuxdriver.com>,
	"kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Julian Calaby" <julian.calaby@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3260 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752026Ab1J2J3N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Oct 2011 05:29:13 -0400
In-Reply-To: <4EAB6495.40707@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/29/2011 04:27 AM, Julian Calaby wrote:
> On 29/10/11 10:58, Julia Lawall wrote:
>> From: Julia Lawall <julia@diku.dk>
>>
>> Delete di->name from the error reporting code, as it is meaningless if di
>> is NULL.
>>
>> The semantic match that finds this problem is as follows:
>> (http://coccinelle.lip6.fr/)
>>
>> // <smpl>
>> @r@
>> expression E, E1;
>> identifier f;
>> statement S1,S2,S3;
>> @@
>>
>> if (E == NULL)
>> {
>>   ... when != if (E == NULL || ...) S1 else S2
>>       when != E = E1
>> *E->f
>>   ... when any
>>   return ...;
>> }
>> else S3
>> // </smpl>
>>
>> Signed-off-by: Julia Lawall <julia@diku.dk>
>>
>> ---
>>  drivers/net/wireless/brcm80211/brcmsmac/dma.c |    2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/wireless/brcm80211/brcmsmac/dma.c b/drivers/net/wireless/brcm80211/brcmsmac/dma.c
>> index b56a302..1d66f53 100644
>> --- a/drivers/net/wireless/brcm80211/brcmsmac/dma.c
>> +++ b/drivers/net/wireless/brcm80211/brcmsmac/dma.c
>> @@ -361,7 +361,7 @@ static uint _dma_ctrlflags(struct dma_info *di, uint mask, uint flags)
>>  	uint dmactrlflags = di->dma.dmactrlflags;
> 
> If di is null, we've already failed as it's dereferenced here.
> 
>>  	if (di == NULL) {
>> -		DMA_ERROR(("%s: _dma_ctrlflags: NULL dma handle\n", di->name));
>> +		DMA_ERROR(("_dma_ctrlflags: NULL dma handle\n"));
>>  		return 0;
>>  	}
> 
> So, a better patch would be something like this:
> 
> (apologies if this doesn't apply - I've pretty much built it manually)
> 
> ---
> 
> Though it's unlikely, di may be null, so we can't dereference
> di->dma.dmactrlflags until we've checked it.
> 
> Move this de-reference after the check, and adjust the error
> message to not require de-referencing di.
> 
> This is based upon Julia's original patch:
> <1319846297-2985-2-git-send-email-julia@diku.dk>
> 
> Reported-by: Julia Lawall <julia@diku.dk>
> Signed-off-by: Julian Calaby <julian.calaby@gmail.com>
> CC: Julia Lawall <julia@diku.dk>
> 
> diff --git a/drivers/net/wireless/brcm80211/brcmsmac/dma.c b/drivers/net/wireless/brcm80211/brcmsmac/dma.c
> index b56a302..6ebec8f 100644
> --- a/drivers/net/wireless/brcm80211/brcmsmac/dma.c
> +++ b/drivers/net/wireless/brcm80211/brcmsmac/dma.c
> @@ -358,13 +358,14 @@ static uint nrxdactive(struct dma_info *di, uint h, uint t
>  
>  static uint _dma_ctrlflags(struct dma_info *di, uint mask, uint flags)
>  {
> -       uint dmactrlflags = di->dma.dmactrlflags;
> +       uint dmactrlflags;
>  
>         if (di == NULL) {
> -               DMA_ERROR(("%s: _dma_ctrlflags: NULL dma handle\n", di->name));
> +               DMA_ERROR(("_dma_ctrlflags: NULL dma handle\n"));
>                 return 0;
>         }
>  
> +       dmactrlflags = di->dma.dmactrlflags;
>         dmactrlflags &= ~mask;
>         dmactrlflags |= flags;
>  
> 
> 
> 
> 

Hi Julian, Julia

That change looks good, but it does not apply on top of our pending
patches. Probably need to resend those after the merge window. I will
create a applying patch and send it to John (and resend later if
needed). Thanks for finding this one.

Gr. AvS
