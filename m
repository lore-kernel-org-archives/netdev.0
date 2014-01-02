From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH 24/31] staging: r8188eu: Additional cleanup of include/odm.h
Date: Thu, 02 Jan 2014 16:04:26 -0600
Message-ID: <52C5E26A.5000704@lwfinger.net>
References: <1387755422-11443-1-git-send-email-Larry.Finger@lwfinger.net> <1387755422-11443-25-git-send-email-Larry.Finger@lwfinger.net> <20140102090516.GB5443@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: gregkh@linuxfoundation.org, devel@driverdev.osuosl.org,
	netdev@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:38851 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751136AbaABWE3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 17:04:29 -0500
Received: by mail-pb0-f46.google.com with SMTP id md12so15024759pbc.33
        for <netdev@vger.kernel.org>; Thu, 02 Jan 2014 14:04:28 -0800 (PST)
In-Reply-To: <20140102090516.GB5443@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/02/2014 03:05 AM, Dan Carpenter wrote:
> On Sun, Dec 22, 2013 at 05:36:55PM -0600, Larry Finger wrote:
>> --- a/drivers/staging/rtl8188eu/include/odm_interface.h
>> +++ b/drivers/staging/rtl8188eu/include/odm_interface.h
>> @@ -51,7 +51,7 @@ ODM_REG(DIG,_pDM_Odm)
>>
>>   #define _cat(_name, _ic_type, _func)					\
>>   	(								\
>> -		((_ic_type) & ODM_IC_11N_SERIES) ? _func##_11N(_name) :	\
>> +		(_ic_type) ? _func##_11N(_name) :			\
>>   		_func##_11AC(_name)					\
>>   	)
>
> The original version of this function was more readable...  I think
> _ic_type is either zero or 16?

The original driver has some code that supports many different chips; however, 
the present one only works for RTL8188E.

In the current driver, ODM_RTL8188E is always the only bit in odm_ic_type, thus 
it is always 16. As a result (_ic_type & ODM_IC_11N_SERIES) is always equal to 
_ic_type, which is why I simplified the macro.

If you really prefer the original version of the macro, I will leave it.

Larry
