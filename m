From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: /proc/sys/net/ipv[46]/conf/ issue unsolved
Date: Tue, 13 Feb 2007 14:43:32 -0500
Message-ID: <45D214E4.9020608@hp.com>
References: <200702131529.04708.hasso@estpak.ee> <20070213185820.GB25362@hmsreliant.homelinux.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Hasso Tepper <hasso@estpak.ee>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.cce.hp.com ([161.114.21.23]:18020 "EHLO
	ccerelrim02.cce.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750839AbXBMTng (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Feb 2007 14:43:36 -0500
In-Reply-To: <20070213185820.GB25362@hmsreliant.homelinux.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Neil Horman wrote:
> On Tue, Feb 13, 2007 at 03:29:04PM +0200, Hasso Tepper wrote:
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
>>
> Can't this simply be fixed by adding a custom udev rule?  Correct me if I'm
> wrong, but the only reason that interfaces come up automatically after their
> appropriate module is inserted is because most distos udev rules issue an ifup
> $DEVICE when they get a creation event for $DEVICE.  Why not add a custom rule
> in for net device creation events to set appropriate sysctl values before the
> ifup is issued.
> 

You can't.  The /proc/sys/conf/eth<x>/  structure appears when the 
interface is marked UP.  At this point, if protocol modules are already
loaded, your configuration parameters are already set.

I was going to ask.. How are you testing Optimistic DAD patch.  The
only way I could do it was to set /proc/sys/conf/default/ipv6  entry.

-vlad
