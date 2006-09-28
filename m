From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [RFC] let mortals use ethtool
Date: Thu, 28 Sep 2006 16:28:08 -0400
Message-ID: <451C3058.8000903@pobox.com>
References: <20060928122514.112a19a8@dxpl.pdx.osdl.net> <1159474625.3741.6.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:31367 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1752001AbWI1U2L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2006 16:28:11 -0400
To: Michael Chan <mchan@broadcom.com>
In-Reply-To: <1159474625.3741.6.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Chan wrote:
> On Thu, 2006-09-28 at 12:25 -0700, Stephen Hemminger wrote:
> 
>> +	/* Allow some commands to be done by anyone */
>> +	switch(ethcmd) {
>> +	case ETHTOOL_GSET:
>> +	case ETHTOOL_GDRVINFO:
>> +	case ETHTOOL_GREGS:
>> +	case ETHTOOL_GWOL:
>> +	case ETHTOOL_GMSGLVL:
>> +	case ETHTOOL_GLINK:
>> +	case ETHTOOL_GCOALESCE:
>> +	case ETHTOOL_GRINGPARAM:
>> +	case ETHTOOL_GPAUSEPARAM:
>> +	case ETHTOOL_GRXCSUM:
>> +	case ETHTOOL_GTXCSUM:
>> +	case ETHTOOL_GSG:
>> +	case ETHTOOL_GSTRINGS:
>> +	case ETHTOOL_PHYS_ID:
>> +	case ETHTOOL_GSTATS:
>> +	case ETHTOOL_GTSO:
>> +	case ETHTOOL_GPERMADDR:
>> +	case ETHTOOL_GUFO:
>> +	case ETHTOOL_GGSO:
> 
> I'm against letting normal users do ETHTOOL_GREGS and ETHTOOL_PHYS_ID.
> Dumping 64K worth of registers and blinking the LEDs should be
> restricted.  But I have no problem doing these checks in the driver if
> necessary.

It is because of issues like these that we should not open up the entire 
list above, all at once.  Each sub-ioctl needs careful consideration and 
driver auditing.

	Jeff



