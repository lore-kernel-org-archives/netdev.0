From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: Cannot set ageing to zero
Date: Tue, 26 Jan 2016 18:48:30 +0100
Message-ID: <20160126174830.GE2195@nanopsycho.orion>
References: <20160126152630.422f5ac4@x240.home>
 <20160126173041.GD2195@nanopsycho.orion>
 <20160126154424.68185099@x240.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>, Scott Feldman <sfeldma@gmail.com>
To: Flavio Leitner <fbl@sysclose.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:34320 "EHLO
	mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964799AbcAZRsd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jan 2016 12:48:33 -0500
Received: by mail-wm0-f46.google.com with SMTP id u188so116744733wmu.1
        for <netdev@vger.kernel.org>; Tue, 26 Jan 2016 09:48:32 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20160126154424.68185099@x240.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Jan 26, 2016 at 06:44:24PM CET, fbl@sysclose.org wrote:
>On Tue, 26 Jan 2016 18:30:41 +0100
>Jiri Pirko <jiri@resnulli.us> wrote:
>
>> Tue, Jan 26, 2016 at 06:26:30PM CET, fbl@sysclose.org wrote:
>> >
>> >Hi,
>> >
>> >After the commit[1] below, we can't set ageing on a Linux bridge
>> >device to zero.  It seems rocker needs the minimum value, but we
>> >can't break an old and valid Linux bridge behavior.   
>> 
>> The commit below adds check if the value being set is within
>> BR_MIN_AGEING_TIME and BR_MAX_AGEING_TIME. I believe that the check is
>> correct as it implements the standard.
>>
>> Why do you set ageing_time to 0? Why don't just just disable learning?
>
>It's a documented behavior:
>http://www.linuxcertif.com/man/5/ifcfg-bridge/
>http://www.linuxfoundation.org/collaborate/workgroups/networking/bridge
>http://comments.gmane.org/gmane.linux.network.bridge/2060

0 makes entries permanent. Fair enough. Feel free to send patch moving
the check inside switchdev_port_attr_set or into drivers. I can put it
in my todo list if you want.

Thanks!


>
>fbl
>
>> 
>> 
>> >
>> >[1] commit c62987bbd8a1a1664f99e89e3959339350a6131e
>> >Author: Scott Feldman <sfeldma@gmail.com>
>> >Date:   Thu Oct 8 19:23:19 2015 -0700
>> >
>> >    bridge: push bridge setting ageing_time down to switchdev
>> >    
>> >    Use SWITCHDEV_F_SKIP_EOPNOTSUPP to skip over ports in bridge that
>> >    don't support setting ageing_time (or setting bridge attrs in
>> >    general). 
>> >    If push fails, don't update ageing_time in bridge and return err
>> > to user. 
>> >    If push succeeds, update ageing_time in bridge and run gc_timer
>> > now to recalabrate when to run gc_timer next, based on new
>> > ageing_time. 
>> >    Signed-off-by: Scott Feldman <sfeldma@gmail.com>
>> >    Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>> >    Acked-by: Jiri Pirko <jiri@mellanox.com>
>> >    Signed-off-by: David S. Miller <davem@davemloft.net>
>> >
>> >
>> >-- 
>> >fbl
>> >  
>
>
>
>-- 
>fbl
>
