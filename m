From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v2 25/26] switchdev: convert swdev_fib_ipv4_add/del
 over to swdev_port_obj_add/del
Date: Fri, 03 Apr 2015 11:00:56 -0700
Message-ID: <551ED558.3020303@gmail.com>
References: <1427882882-2533-1-git-send-email-sfeldma@gmail.com> <1427882882-2533-26-git-send-email-sfeldma@gmail.com> <551C094D.7000707@cumulusnetworks.com> <20150401160522.GE2025@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: sfeldma@gmail.com, netdev@vger.kernel.org, linux@roeck-us.net,
	sridhar.samudrala@intel.com, ronen.arad@intel.com
To: Jiri Pirko <jiri@resnulli.us>, roopa <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:33026 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752428AbbDCSBu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Apr 2015 14:01:50 -0400
Received: by paboj16 with SMTP id oj16so41678297pab.0
        for <netdev@vger.kernel.org>; Fri, 03 Apr 2015 11:01:49 -0700 (PDT)
In-Reply-To: <20150401160522.GE2025@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/04/15 09:05, Jiri Pirko wrote:
>> This looks nice. However, my only concern is we have now ended up adding a
>> whole layer of abstraction to all objects. The api abstraction seemed fine.
>> But, carrying it to objects and duplicating every object in the swdev layer
>> seems too much duplication. Maybe its just me.
>> we will end up adding this for bond attributes...vxlan...fdb and nftables
> 
> +1

+1.

> 
>> etc.
>>
>> The advantage of switchdev in the kernel was to have access the existing
>> kernel api and objects directly from switchdev layer.
>> In which case, to me, it would be better to skip this extra layer of objects.
>> And keep the way you had it originally.

Same here, I am not exactly sure how much good the abstract object is
giving us here since we are already in the kernel, and we cannot/do not
necessarily want to eliminate a large number of swdev_ops, as these are
precisely the API we want to define.

NB: if we were to do that for swdev_ops, the next step would be doing
the same thing for netdev_ops to reduce their number, would not we?

Maybe for now solving the stacked device problem and
prepare/commit/rollback is good enough to keep you busy that adding the
object layer is a completely secondary problem to solve ;)?
-- 
Florian
