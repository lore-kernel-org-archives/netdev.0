From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [patch 1/1] sis900 transceiver fix
Date: Thu, 27 May 2004 14:09:52 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40B62EF0.2050003@pobox.com>
References: <200405250938.i4P9cor08103@mail.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: akpm@osdl.org, grischa@bitclown.de
In-Reply-To: <200405250938.i4P9cor08103@mail.osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

akpm@osdl.org wrote:
> From: Grischa Jacobs <grischa@bitclown.de>
> 
> I had the same messages about unknown PHY transceivers and very poor transfer
> rates.  I figured that all but one of the transceivers had the status bit
> MII_STAT_FAULT set.  Selecting that one solved my problems.
> 
> I posted this and the patch already a while ago but didn't get any response. 
> It would be nice if a few people could check whether this fixes/breaks it for
> them.
> 
> I just checked it with 2.6.6-rc3 and the problem is still there and gets
> solved by the attached patch.
> 
> 
> ---
> 
>  25-akpm/drivers/net/sis900.c |    5 +++++
>  1 files changed, 5 insertions(+)
> 
> diff -puN drivers/net/sis900.c~sis900-xcvr-fix drivers/net/sis900.c
> --- 25/drivers/net/sis900.c~sis900-xcvr-fix	Wed May 19 14:51:16 2004
> +++ 25-akpm/drivers/net/sis900.c	Wed May 19 14:51:16 2004
> @@ -18,6 +18,7 @@
>     preliminary Rev. 1.0 Jan. 18, 1998
>     http://www.sis.com.tw/support/databook.htm
>  
> +               Jan.  7 2004 Grischa Jacobs - Skip mii's with MII_STAT_FAULT set
>     Rev 1.08.07 Nov.  2 2003 Daniele Venzano <webvenza@libero.it> add suspend/resume support
>     Rev 1.08.06 Sep. 24 2002 Mufasa Yang bug fix for Tx timeout & add SiS963 support
>     Rev 1.08.05 Jun.  6 2002 Mufasa Yang bug fix for read_eeprom & Tx descriptor over-boundary
> @@ -546,6 +547,10 @@ static int __init sis900_mii_probe (stru
>  			/* the mii is not accessible, try next one */
>  			continue;
>  		
> +		if (mii_status & MII_STAT_FAULT)
> +			/* ignore mii with the fault bit set */
> +			continue;

Rejected.  The driver should just be checking for 0xffff like the other 
drivers.

Please always cc netdev@oss.sgi.com for net driver patches, for greater 
review (and also to increase the number of people that will harrass me 
when a patch isn't speedily applied)

	Jeff
