From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: /proc/sys/net/ipv[46]/conf/ issue unsolved
Date: Tue, 13 Feb 2007 13:04:26 -0500
Message-ID: <45D1FDAA.6070704@hp.com>
References: <200702131529.04708.hasso@estpak.ee> <20070213090224.2826859f@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Hasso Tepper <hasso@estpak.ee>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ccerelrim03.cce.hp.com ([161.114.21.24]:32357 "EHLO
	ccerelrim03.cce.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751531AbXBMSiT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Feb 2007 13:38:19 -0500
In-Reply-To: <20070213090224.2826859f@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> On Tue, 13 Feb 2007 15:29:04 +0200
> Hasso Tepper <hasso@estpak.ee> wrote:
> 
>> There is long standing issue in kernel which makes using /etc/sysctl.conf
>> useless for boottime configuration of specific interface properties and
>> breaks probably any software relying on unconditional existence of the
>> conf trees like it was in previous kernels (I alone have written several
>> pieces of such software). It's broken AFAIK from 2.6.15. There has been
>> several notes about issue in the list, but issue haven't got any (at least
>> efficient) attention from developers.
>>
>> The current behaviour bites users in many ways and breaks several use cases.
>> I asked several times in the past "what I should do now?" question, but
>> got no clear answer.
>>
>> References:
>> http://marc.theaimsgroup.com/?l=linux-netdev&m=115685059625467&w=2
>> http://marc.theaimsgroup.com/?l=linux-netdev&m=115690828822486&w=2
>> https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=169809
>>
>> Is there any chance this will be fixed or at least clear position is
>> taken by developers? Breaking userspace applications is declared nonono
>> several times in the past ... I'm not even against breaking it if there
>> is _very_ good reason to do it. Ok, but I want to know how userspace is
>> meant to behave now. I can't continue using crappy workarounds.
> 
> As Herbert Xu said:
> 
>> You can disable it in /proc/sys/net/ipv6/conf/default/... and then
>> reenable it on the interfaces that you actually want.
> 

Sorry, but this is backwards.

Let's say you have an interface on which you want to turn DAD off.

There are ways to do it:

1.  Turn DAD off on all interfaces usinc ipv6/conf/default and then
     turn it on just on the interface you want.

This solution is a royal pain and introduces a potential race
on the interfaces that should have DAD enabled (i.e. you address will
be preferred when it really should be tentative).

2.  Wait until the interface is up and then turn off dad.

However at this point, DAD may have completely already so turning it off
is useless to us.

There needs to be a mechanism by which protocol parameters may be 
changed on the interface bases before the interface is up/running.

This has been bugging me for while too.

-vlad
