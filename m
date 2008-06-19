From: Dmitry <dbaryshkov@gmail.com>
Subject: Re: [PATCH] RFKILL: fix input layer initialisation
Date: Fri, 20 Jun 2008 02:28:20 +0400
Message-ID: <bc64b4640806191528g67ec856av7caf886e8e7c1975@mail.gmail.com>
References: <20080619112841.GA12051@doriath.ww600.siemens.net>
	 <200806192049.54798.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Ivo van Doorn" <ivdoorn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.232]:12153 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751375AbYFSW2V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jun 2008 18:28:21 -0400
Received: by rv-out-0506.google.com with SMTP id k40so5384913rvb.1
        for <netdev@vger.kernel.org>; Thu, 19 Jun 2008 15:28:20 -0700 (PDT)
In-Reply-To: <200806192049.54798.IvDoorn@gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

2008/6/19 Ivo van Doorn <ivdoorn@gmail.com>:
> On Thursday 19 June 2008, Dmitry Baryshkov wrote:
>> Initialise correctly last fields, so tasks can be actually executed
>>
>> Also move rfkill-input initialisation to subsys level so that it's
>> available before generic drivers probing occurs.
>>
>> Signed-off-by: Dmitry Baryshkov <dbaryshkov@gmail.com>
>> ---
>>  net/rfkill/rfkill-input.c |    7 ++++++-
>>  1 files changed, 6 insertions(+), 1 deletions(-)
>>
>> diff --git a/net/rfkill/rfkill-input.c b/net/rfkill/rfkill-input.c
>> index e4b051d..e4540fc 100644
>> --- a/net/rfkill/rfkill-input.c
>> +++ b/net/rfkill/rfkill-input.c
>> @@ -181,6 +181,11 @@ static struct input_handler rfkill_handler = {
>>
>>  static int __init rfkill_handler_init(void)
>>  {
>> +     unsigned long last_run = jiffies - msecs_to_jiffies(500);
>> +     rfkill_wlan.last = last_run;
>> +     rfkill_bt.last = last_run;
>> +     rfkill_uwb.last = last_run;
>> +     rfkill_wimax.last = last_run;
>
> I'm not really fan of this approach
> Can't this not be done someway in the DEFINE_RFKILL_TASK macro
> where the entire structure is initialized?
> That way it will automatically be set for all new rfkill task structures later.

IMHO it can't. the jiffies - mset_to_jiffies isn't a constant
initialiser; gcc won't permit such a thing

>
>>       return input_register_handler(&rfkill_handler);
>>  }
>>
>> @@ -190,5 +195,5 @@ static void __exit rfkill_handler_exit(void)
>>       flush_scheduled_work();
>>  }
>>
>> -module_init(rfkill_handler_init);
>> +subsys_initcall(rfkill_handler_init);
>>  module_exit(rfkill_handler_exit);
>
> This sounds good.
>
> Ivo
>



-- 
With best wishes
Dmitry
