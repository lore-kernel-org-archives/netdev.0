From: Veaceslav Falico <vfalico@gmail.com>
Subject: Re: [PATCH net-next] net: print a notification on device rename
Date: Sun, 20 Jul 2014 23:17:59 +0200
Message-ID: <20140720211759.GA28467@mikrodark.usersys.redhat.com>
References: <1405622012-5511-1-git-send-email-vfalico@gmail.com>
 <B5657A6538887040AD3A81F1008BEC63B01758@avmb3.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Vlad Yasevich <vyasevic@redhat.com>,
	stephen hemminger <stephen@networkplumber.org>,
	Jerry Chu <hkchu@google.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	David Laight <David.Laight@ACULAB.COM>
To: Yuval Mintz <Yuval.Mintz@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:46899 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750835AbaGTVU7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jul 2014 17:20:59 -0400
Received: by mail-wi0-f174.google.com with SMTP id d1so3178205wiv.1
        for <netdev@vger.kernel.org>; Sun, 20 Jul 2014 14:20:58 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <B5657A6538887040AD3A81F1008BEC63B01758@avmb3.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jul 20, 2014 at 12:37:52PM +0000, Yuval Mintz wrote:
>> Currently it's done silently (from the kernel part), and thus it might be hard to
>> track the renames from logs.
>>
>> Add a simple netdev_info() to notify the rename, but only in case the previous
>> name was valid.
>
>Hi,
>
>Why you're at it, perhaps we could also consider adding an optional ndo callback
>in the drivers to notify them of the device name change?
>[e.g., multi-module dependencies where one would wish to inform the others
>of the name change]

There's already one, I think:

1142         ret = call_netdevice_notifiers(NETDEV_CHANGENAME, dev);

It's also possible to block it. Or did you mean something else?

Thank you!

>
>Cheers,
>Yuval
>
>>
>> CC: "David S. Miller" <davem@davemloft.net>
>> CC: Eric Dumazet <edumazet@google.com>
>> CC: Vlad Yasevich <vyasevic@redhat.com>
>> CC: stephen hemminger <stephen@networkplumber.org>
>> CC: Jerry Chu <hkchu@google.com>
>> CC: Ben Hutchings <bhutchings@solarflare.com>
>> CC: David Laight <David.Laight@ACULAB.COM>
>> Signed-off-by: Veaceslav Falico <vfalico@gmail.com>
>> ---
>>  net/core/dev.c | 3 +++
>>  1 file changed, 3 insertions(+)
>>
>> diff --git a/net/core/dev.c b/net/core/dev.c index 239722a..d14ebf0 100644
>> --- a/net/core/dev.c
>> +++ b/net/core/dev.c
>> @@ -1113,6 +1113,9 @@ int dev_change_name(struct net_device *dev, const
>> char *newname)
>>               return err;
>>       }
>>
>> +     if (oldname[0] && !strchr(oldname, '%'))
>> +             netdev_info(dev, "renamed from %s\n", oldname);
>> +
>>       old_assign_type = dev->name_assign_type;
>>       dev->name_assign_type = NET_NAME_RENAMED;
>>
>
>________________________________
>
>This message and any attached documents contain information from QLogic Corporation or its wholly-owned subsidiaries that may be confidential. If you are not the intended recipient, you may not read, copy, distribute, or use this information. If you have received this transmission in error, please notify the sender immediately by reply e-mail and then delete this message.
