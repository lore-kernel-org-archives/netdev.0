From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH 2/2] net: dsa: register hwmon for any provided function
Date: Thu, 16 Apr 2015 19:17:36 -0700
Message-ID: <55306D40.1060604@roeck-us.net>
References: <1429209499-2447-1-git-send-email-vivien.didelot@savoirfairelinux.com> <1429209499-2447-2-git-send-email-vivien.didelot@savoirfairelinux.com> <20150416212638.GB2587@roeck-us.net> <973411308.896485.1429221939679.JavaMail.zimbra@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	kernel@savoirfairelinux.com
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:34785 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752604AbbDQCSA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2015 22:18:00 -0400
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1Yivqy-002xDz-8L
	for netdev@vger.kernel.org; Fri, 17 Apr 2015 02:18:00 +0000
In-Reply-To: <973411308.896485.1429221939679.JavaMail.zimbra@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hi Vivien,

On 04/16/2015 03:05 PM, Vivien Didelot wrote:
> Hi Guenter,
>
>>>           switch (index) {
>>> +        case 0: /* temp1_input */
>>> +                if (drv->get_temp)
>>> +                        mode |= S_IRUGO;
>>
>> This should be mandatory. Sorry, I don't really understand what you are
>> trying to accomplish here.
>>
>> Can you give me a real world example where a chip would support setting
>> a limit but not reading it ?
>
> I have no such example. I just did not see why this couldn't be allowed
> (e.g. setting only set_temp_limit and get_temp_alarm looks fine to me).
> But if you say that get_temp should be mandatory, I'm OK with that.
>
write-only attributes are not defined in the hwmon ABI. If the 'sensors'
command encounters such an attribute, it will create an error message
each time it executes. That doesn't sound very useful to me.

If a chip - for whatever reason - does not have a limit register
but an alarm register or flag, its temperature limit is usually hard-coded
and can be reported this way (the AMD temperature sensor driver does this,
for example). If there is ever a need to support the alarm-register-only
situation for some odd reason, we can add the code at the time.
For now, it just seems to me that you are adding complexity to solve
some theoretic problem which is very unlikely to occur in the real world.

> The primary goal of this patchset was to use DEVICE_ATTR_RW to declare
> temp1_max, instead of reflecting the minimal permissions needed.
>
Then why don't you just do that and nothing else ? The goal should be
to simplify code, not to make it more complicated. If the result isn't
less code, I don't think it is worth it.

Thanks,
Guenter
