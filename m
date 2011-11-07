From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH net-next] sweep the floors and convert some .get_drvinfo
 routines to strlcpy
Date: Mon, 07 Nov 2011 14:14:17 -0800
Message-ID: <4EB85839.8090503@hp.com>
References: <20111107215649.95F372900440@tardy> <1320703902.3020.74.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Rick Jones <raj@tardy.cup.hp.com>, netdev@vger.kernel.org,
	David Dillow <dave@thedillows.org>,
	Steffen Klassert <klassert@mathematik.tu-chemnitz.de>,
	Ion Badulescu <ionut@badula.org>,
	Jay Cliburn <jcliburn@gmail.com>,
	Chris Snook <chris.snook@gmail.com>,
	Michael Chan <mchan@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>,
	Matt Carlson <mcarlson@broadcom.com>,
	Rasesh Mody <rmody@brocade.com>,
	Grant Grundler <grundler@parisc-linux.org>,
	Ajit Khaparde <ajit.khaparde@emulex.com>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Tim Hockin <thockin@hockin.org>, Jon Mason <jdmason@kudzu.us>,
	Sony Chacko <sony.chacko@qlogic.com>,
	Anirban Chakraborty <anirban.chakraborty@qlogic.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Steve Glendinning <steve.glendinning@smsc.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0029.austin.hp.com ([15.216.28.36]:48518 "EHLO
	g1t0029.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751067Ab1KGWOX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Nov 2011 17:14:23 -0500
In-Reply-To: <1320703902.3020.74.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/07/2011 02:11 PM, Ben Hutchings wrote:
> On Mon, 2011-11-07 at 13:56 -0800, Rick Jones wrote:
>> From: Rick Jones<rick.jones2@hp.com>
>>
>> Per the mention made by Ben Hutchings that strlcpy is now the preferred
>> string copy routine for a .get_drvinfo routine, do a bit of floor
>> sweeping and convert some of the as-yet unconverted ethernet drivers to
>> it.
> [...]
>> diff --git a/drivers/net/ethernet/3com/3c589_cs.c b/drivers/net/ethernet/3com/3c589_cs.c
>> index 972f80e..5e91602 100644
>> --- a/drivers/net/ethernet/3com/3c589_cs.c
>> +++ b/drivers/net/ethernet/3com/3c589_cs.c
>> @@ -468,9 +468,10 @@ static void tc589_reset(struct net_device *dev)
>>   static void netdev_get_drvinfo(struct net_device *dev,
>>   			       struct ethtool_drvinfo *info)
>>   {
>> -	strcpy(info->driver, DRV_NAME);
>> -	strcpy(info->version, DRV_VERSION);
>> -	sprintf(info->bus_info, "PCMCIA 0x%lx", dev->base_addr);
>> +	strlcpy(info->driver, DRV_NAME, sizeof(info->driver));
>> +	strlcpy(info->version, DRV_VERSION, sizeof(info->version));
>> +	snprintf(info->bus_info, sizeof(info->bus_info) - 1,
>> +		"PCMCIA 0x%lx", dev->base_addr);
> [...]
>
> snprintf(), like strlcpy(), will always write a null terminator in the
> buffer it is given (unless the buffer size is 0).  Therefore it is
> incorrect to subtract 1 from the actual buffer size.

I will fix those and resend.  Thanks.

rick jones
