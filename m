From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH] ipv6: do not add link-local address if one already exists
Date: Wed, 13 Aug 2014 19:10:27 +0200
Message-ID: <20140813171027.GC1869@nanopsycho.orion>
References: <d630f87aa617098553c3a3361fcf50aa@mail.marples.name>
 <1407703032.2161.22.camel@localhost>
 <c612bb8cad5480b08919e32f39c6d6ea@mail.marples.name>
 <1407715900.2161.24.camel@localhost>
 <5734a020ebb2bd95d61ba282243719bd@mail.marples.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hannes Frederic Sowa <hannes@redhat.com>, netdev@vger.kernel.org
To: Roy Marples <roy@marples.name>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:36121 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752831AbaHMRKa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2014 13:10:30 -0400
Received: by mail-wi0-f169.google.com with SMTP id n3so8707128wiv.0
        for <netdev@vger.kernel.org>; Wed, 13 Aug 2014 10:10:29 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <5734a020ebb2bd95d61ba282243719bd@mail.marples.name>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Aug 11, 2014 at 11:22:04PM CEST, roy@marples.name wrote:
>Hi
>
>On 2014-08-11 01:11, Hannes Frederic Sowa wrote:
>>On Mo, 2014-08-11 at 00:05 +0000, Roy Marples wrote:
>>>On 2014-08-10 20:37, Hannes Frederic Sowa wrote:
>>>> On So, 2014-08-10 at 19:56 +0000, Roy Marples wrote:
>>>>> Currently the kernel will always add an IPv6 link-local address
>>>>> based on the hardware address when the interface is brought up.
>>>>> This is probably based on the assumption that userland would
>>>>> never add one before the interface is brought up.
>>>>>
>>>>> However, one at least one userland application (dhcpcd) does this so
>>>>> it can implement RFC7217 which can be used for link-local addresses
>>>>> as well.
>>>>>
>>>>> Attached is a patch which checks to see if a link-local address exists
>>>>> before indiscriminately adding one.
>>>>
>>>> Please have a look at:
>>>> https://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/?id=bc91b0f07ada5535427373a4e2050877bcc12218
>>>>
>>>> This was recently implemented just for this specific case.
>>>
>>>Is that tunable available in /proc or /sys?
>>>I'm not overly keen on adding a netlink call just for that in dhcpcd, it
>>>would be a lot of bloat compared to the kernel patch.
>>
>>Can you call iproute via a script? Would that fit your needs?
>>https://git.kernel.org/cgit/linux/kernel/git/shemminger/iproute2.git/commit/?h=net-next&id=ff7c20844049be836c10087cb2418b99ff36ca2b
>
>Not really as there is no guarantee iproute2 is installed on the host.
>For now, I've added a netlink call at the expense of around 400 bytes.

The iface to idev->addr_gen_mode can be certainly added to sysfs. Feel
free to do so.


>
>Thanks
>
>Roy
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
