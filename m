From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] Remove broken netfilter binary sysctls from bridging
 code
Date: Tue, 25 Sep 2007 18:22:36 +0200
Message-ID: <46F935CC.20400@trash.net>
References: <20070918011841.2381bd93.akpm@linux-foundation.org>	<20070921020554.GE31759@nineveh.local>	<m1fy18k5ru.fsf@ebiederm.dsl.xmission.com>	<46F7EC0A.9030506@trash.net>	<20070924131458.0daa4562@freepuppy.rosehill>	<46F8897C.5010504@trash.net> <20070925091203.371879e2@fujitsu-loaner>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:38941 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752730AbXIYQZG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Sep 2007 12:25:06 -0400
In-Reply-To: <20070925091203.371879e2@fujitsu-loaner>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> On Tue, 25 Sep 2007 06:07:24 +0200
> Patrick McHardy <kaber@trash.net> wrote:
>
>   
>> I meant removing brnf_sysctl_call_tables function, not the sysctls
>> themselves, all it does is change values != 0 to 1. Or did you
>> actually mean that something in userspace might depend on reading
>> back the value 1 after writing a value != 0?
>>     
>
> I was going farther, because don't really see the value of having
> a sysctl for this. It seems better to just not load filters if
> they aren't going to be used. Having another enable/disable hook
> just adds needless complexity.
>   

These sysctls control whether bridged packets will be handled
by iptables and friends. The bridge netfilter code always
handles bridged packets, and iptables might be loaded for
different reasons. So I don't see how that would work.

I think it should be specified in the ebtables ruleset, but
the current netfilter infrastructure doesn't allow to do that
cleanly.


