From: Veaceslav Falico <vfalico@gmail.com>
Subject: Re: [PATCH v2 net-next 2/2] net: print net_device reg_state in
 netdev_* unless it's registered
Date: Thu, 17 Jul 2014 19:27:41 +0200
Message-ID: <20140717172741.GC20406@mikrodark.usersys.redhat.com>
References: <1405606186-13703-1-git-send-email-vfalico@gmail.com>
 <1405606186-13703-3-git-send-email-vfalico@gmail.com>
 <1405616424.12363.47.camel@joe-AO725>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Jason Baron <jbaron@akamai.com>,
	Eric Dumazet <edumazet@google.com>,
	Vlad Yasevich <vyasevic@redhat.com>,
	stephen hemminger <stephen@networkplumber.org>,
	Jerry Chu <hkchu@google.com>,
	Ben Hutchings <bhutchings@solarflare.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:39324 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750737AbaGQRan (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2014 13:30:43 -0400
Received: by mail-wi0-f169.google.com with SMTP id n3so7527937wiv.0
        for <netdev@vger.kernel.org>; Thu, 17 Jul 2014 10:30:41 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1405616424.12363.47.camel@joe-AO725>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 17, 2014 at 10:00:24AM -0700, Joe Perches wrote:
>On Thu, 2014-07-17 at 16:09 +0200, Veaceslav Falico wrote:
>> This way we'll always know in what status the device is, unless it's
>> running normally (i.e. NETDEV_REGISTERED).
>[]
>> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>[]
>> @@ -3388,6 +3388,20 @@ static inline const char *netdev_name(const struct net_device *dev)
>>  	return dev->name;
>>  }
>>
>> +static inline const char *netdev_reg_state(const struct net_device *dev)
>> +{
>> +	switch (dev->reg_state) {
>> +	case NETREG_UNINITIALIZED: return " (unregistered)";
>
>Why not " (uninitialized)"?

Good one, thank you, missed it somehow. Will send v2.

>
>> +	case NETREG_REGISTERED: return "";
>> +	case NETREG_UNREGISTERING: return " (unregistering)";
>> +	case NETREG_UNREGISTERED: return " (unregistered)";
>> +	case NETREG_RELEASED: return " (released)";
>> +	case NETREG_DUMMY: return " (dummy)";
>> +	}
>> +
>> +	return " (unknown)";
>
>Shouldn't this " (unknown)" have stronger text
>and use a WARN_ON_ONCE?

Hrm, I don't remember why, but I've specifically dropped the warning here.
Now it seems like a good idea, so I'll add it here.

>
>I'd put this in net/core/dev.c and make it not be static inline.

Again, I don't think it's really needed, as it's used in 4 functions (which
aren't inline), so the benefits are minimal, if any.

I'll rather keep them inline, I guess...

>
>
