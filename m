From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 0/4] net: allow to change carrier from userspace
Date: Wed, 12 Dec 2012 18:05:20 +0100
Message-ID: <20121212170520.GA3060@minipsycho.orion>
References: <1355309887-1081-1-git-send-email-jiri@resnulli.us>
 <20121212081500.24085752@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com,
	bhutchings@solarflare.com, mirqus@gmail.com,
	greearb@candelatech.com, fbl@redhat.com
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:56255 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754466Ab2LLRFZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2012 12:05:25 -0500
Received: by mail-ee0-f46.google.com with SMTP id e53so633391eek.19
        for <netdev@vger.kernel.org>; Wed, 12 Dec 2012 09:05:24 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20121212081500.24085752@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Dec 12, 2012 at 05:15:00PM CET, shemminger@vyatta.com wrote:
>On Wed, 12 Dec 2012 11:58:03 +0100
>Jiri Pirko <jiri@resnulli.us> wrote:
>
>> This is basically a repost of my previous patchset:
>> "[patch net-next-2.6 0/2] net: allow to change carrier via sysfs" from Aug 30
>> 
>> The way net-sysfs stores values changed and this patchset reflects it.
>> Also, I exposed carrier via rtnetlink iface.
>> 
>> So far, only dummy driver uses carrier change ndo. In very near future
>> team driver will use that as well.
>> 
>> Jiri Pirko (4):
>>   net: add change_carrier netdev op
>>   net: allow to change carrier via sysfs
>>   rtnl: expose carrier value with possibility to set it
>>   dummy: implement carrier change
>> 
>>  drivers/net/dummy.c          | 10 ++++++++++
>>  include/linux/netdevice.h    |  7 +++++++
>>  include/uapi/linux/if_link.h |  1 +
>>  net/core/dev.c               | 19 +++++++++++++++++++
>>  net/core/net-sysfs.c         | 15 ++++++++++++++-
>>  net/core/rtnetlink.c         | 10 ++++++++++
>>  6 files changed, 61 insertions(+), 1 deletion(-)
>> 
>
>I needed to do the same thing for a project we are working on and discovered
>that there already is a working documented interface for doing that via
>operstate mode. Therefore I can't recommend that the additional complexity
>of a new API for this is required.

I might be missing something, but I'm unable to find how operstate set
can affect value returned by netif_carrier_ok()
