From: Andy Fleming <afleming@freescale.com>
Subject: Re: [PATCH v2.6.26] gianfar: Determine TBIPA value dynamically
Date: Fri, 11 Apr 2008 14:06:07 -0500
Message-ID: <1D6963B0-4EC5-41F7-8BFA-97C2C0647A13@freescale.com>
References: <1207870471-3601-1-git-send-email-afleming@freescale.com> <20080411153125.GA2588@loki.buserror.net>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paul.gortmaker@windriver.com,
	linuxppc-dev@ozlabs.org
To: Scott Wood <scottwood@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw01.freescale.net ([192.88.158.102]:43204 "EHLO
	az33egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760635AbYDKTGQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Apr 2008 15:06:16 -0400
In-Reply-To: <20080411153125.GA2588@loki.buserror.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Apr 11, 2008, at 10:31, Scott Wood wrote:

> On Thu, Apr 10, 2008 at 06:34:31PM -0500, Andy Fleming wrote:
>>
>> +	/*
>> +	 * This is mildly evil, but so is our hardware for doing this.
>> +	 * Also, we have to cast back to struct gfar_mii because of
>> +	 * definition weirdness done in gianfar.h.
>> +	 */
>> +	enet_regs = (struct gfar __iomem *)
>> +		((char *)regs - offsetof(struct gfar, gfar_mii_regs));
>
> Can we use to_container() here?


I tried.  Technically, we can.  But the issue is that struct gfar  
*enet_regs->gfar_mii_regs is declared:

u8 gfar_mii_regs[24];

I could not find any sequence of castings that made the warning go  
away about casting that to a struct gfar_mii __iomem *.  And that  
includes mucking around with the declaration of gfar_mii_regs.  I  
vaguely recall determining that you couldn't make it a struct, because  
you can't guarantee gcc won't much with the size of the struct.  Or  
something.  Suffice it to say, this worked, and wasn't much wordier.   
But I really did spend a couple hours banging my head against sparse  
trying to get the pointers to agree.

Andy
