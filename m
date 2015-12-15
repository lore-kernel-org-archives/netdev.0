From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] sh_eth: fix descriptor access endianness
Date: Tue, 15 Dec 2015 21:06:16 +0300
Message-ID: <56705698.9010703@cogentembedded.com>
References: <11070795.yxBPvlHg4n@wasted.cogentembedded.com>
 <20151215.002541.762812772082527155.davem@davemloft.net>
 <566FF8FB.2010005@cogentembedded.com>
 <20151215.125336.1876941788722356501.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f53.google.com ([209.85.215.53]:34972 "EHLO
	mail-lf0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965325AbbLOSGU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Dec 2015 13:06:20 -0500
Received: by mail-lf0-f53.google.com with SMTP id l133so12584518lfd.2
        for <netdev@vger.kernel.org>; Tue, 15 Dec 2015 10:06:20 -0800 (PST)
In-Reply-To: <20151215.125336.1876941788722356501.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/15/2015 08:53 PM, David Miller wrote:

>>>> The driver never calls cpu_to_edmac() when writing the descriptor
>>>> address
>>>> and edmac_to_cpu() when reading it, although it should -- fix this.
>>>>
>>>> Note that the frame/buffer length descriptor field accesses also need
>>>> fixing
>>>> but since they are both 16-bit we can't use
>>>> {cpu|edmac}_to_{edmac|cpu}()...
>>>>
>>>> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
>>>
>>> Applied.
>>
>>     I was going to rework this to fix _all_ cases, and sent follow-up
>>     email about that yesterday... Haven't you received it?
>
> I saw it but you were not entirely clear whether you were going to do
> that work in a follow-on patch or not.
>
> If you don't clearly say "Dave, please drop this patch." expect me to
> do random things.

    Previously I had a plan to get rid of never used EDMAC_BIG_ENDIAN and then 
get rid of {edmac|cpu}_to_{cpu|edmac}() and fix 16-bit descriptor R/W by using 
{cpu|le32}_to_{le32|cpu}(). How's that plan to you?

MBR, Sergei
