From: "Kay Sievers" <kay.sievers@vrfy.org>
Subject: Re: [PATCH] netdev: generate kobject uevent on network state transitions
Date: Wed, 26 Nov 2008 13:09:35 +0100
Message-ID: <ac3eb2510811260409q2da4a31eja872831f377e96bc@mail.gmail.com>
References: <20081124150347.73050f98@extreme>
	 <AAE2573A-3C23-4C61-89E1-3A6F31D7B23E@holtmann.org>
	 <20081124201440.0e4d61cc@extreme>
	 <20081125.010943.205685748.davem@davemloft.net>
	 <FB30A309-CE17-43E7-8B5B-BC276E849720@holtmann.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, shemminger@vyatta.com,
	bhutchings@solarflare.com, linux-hotplug@vger.kernel.org,
	netdev@vger.kernel.org
To: "Marcel Holtmann" <marcel@holtmann.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.175]:20417 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752138AbYKZMJh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2008 07:09:37 -0500
Received: by ug-out-1314.google.com with SMTP id 39so1390471ugf.37
        for <netdev@vger.kernel.org>; Wed, 26 Nov 2008 04:09:36 -0800 (PST)
In-Reply-To: <FB30A309-CE17-43E7-8B5B-BC276E849720@holtmann.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 26, 2008 at 06:24, Marcel Holtmann <marcel@holtmann.org> wrote:
>>>>> It is easier for some applications to deal with text based interfaces
>>>>> like uevent, rather than using netlink to listen for events.
>>>>>
>>>>> Note, this does not deal with network namespaces but that is a generic
>>>>> problem that already exists with kobjects (see rename events).
>>>>>
>>>>> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>> ...
>>>> do we wanna copy just what ifconfig shows or do we might be a more
>>>> intelligent and have separate variables like RUNNING=1 etc.?
>>>
>>> Was arbitrary choice to just use same flags as existing ifconfig.
>>> What ever feels best I guess...
>>
>> So what do folks want me to do here?  Should I put Stephen's
>> latest patch in, or do we want to make some kind of flags change?
>
> I am thinking of using per value variables. My personal choice.
>
> Kay, any pointers or opinions from you?

As long as we can match values with fnmatch(), it should all work fine.

Bitmasks are fine if represented as binary strings, otherwise, like
for hex strings, the fnmatch() looks really weird.

As long as no string value in the list is contained in another value,
like matching for RUNNING, IS_RUNNING, RUNNING2 would be, it's fine to
stuff them all in one string just separated by comma. If they can ever
overlap, we would need to add the comma also to the beginning and end
of the string, to be able to put it into the match string like
"*,RUNNING,*", to avoid wrong matches by partial string matches.

I leave it up to you, I'm fighting with really weird things in some
other subsystems, so all of the possible options here for the net
events look pretty to me, and should work fine, compared to some stuff
I'm used to. :)

Thanks,
Kay
