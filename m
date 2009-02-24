From: Tobias Winter <tobias@linuxdingsda.de>
Subject: Re: [Bugme-new] [Bug 12772] New: linux is not able to handle more
 than ~4096 ipv6 addresses
Date: Tue, 24 Feb 2009 21:07:47 +0100
Message-ID: <49A45393.5040307@linuxdingsda.de>
References: <bug-12772-10286@http.bugzilla.kernel.org/> <20090224115059.807f5246.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	yoshfuji@linux-ipv6.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from projekt-pegel.de ([88.198.5.81]:45258 "EHLO
	static.88-198-5-81.clients.your-server.de" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757978AbZBXU0H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2009 15:26:07 -0500
In-Reply-To: <20090224115059.807f5246.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Point taken. I just gave it a try with 2.6.29-rc6 and the problem persists.


Andrew Morton wrote:
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
> 
> On Tue, 24 Feb 2009 11:35:25 -0800 (PST)
> bugme-daemon@bugzilla.kernel.org wrote:
> 
>> http://bugzilla.kernel.org/show_bug.cgi?id=12772
>>
>>            Summary: linux is not able to handle more than ~4096 ipv6
>>                     addresses
>>            Product: Networking
>>            Version: 2.5
>>      KernelVersion: 2.6.26-1-amd64 #1 SMP Sat Jan 10 19:55:48 UTC 2009
>>                     x86_64 GNU/Li
> 
> That's a fairly old kernel.
> 
>>           Platform: All
>>         OS/Version: Linux
>>               Tree: Mainline
>>             Status: NEW
>>           Severity: normal
>>           Priority: P1
>>          Component: IPV6
>>         AssignedTo: yoshfuji@linux-ipv6.org
>>         ReportedBy: tobias@linuxdingsda.de
>>
>>
>> Latest working kernel version: --
>> Earliest failing kernel version: --
>> Distribution: Debian sid
>> Hardware Environment: model name      : Intel(R) Pentium(R) Dual  CPU  E2180  @
>> 2.00GHz
>> Software Environment: 
>> Problem Description:
>> Linux is unable to handle more than ~4096 ipv6 addresses and usually crashes
>> after a not very long time. If not, it at least gets unusable slow.
>>
>> Consider shared hosting environments, where you have some few thousand
>> customers with a few domains each sitting on one box. You now would like to use
>> ipv6 for greater fun with https and, for that, need about 6-30k addresses bound
>> to the box.
>>
>>
>> Steps to reproduce:
>>
>> #!/bin/bash 
>> COUNTER=1
>> COUNTERR=1
>> while [  $COUNTERR -lt 9999 ]; do
>>         while [  $COUNTER -lt 9999 ]; do
>>                 ip addr add 2001::$COUNTERR:$COUNTER/64 dev eth1
>>                 let COUNTER=COUNTER+1
>>                 echo $CONTERR $COUNTER
>>         done
>> let COUNTERR=COUNTER+1
>> done
>>
> 
