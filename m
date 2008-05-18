From: Patrick McHardy <kaber@trash.net>
Subject: Re: [Bugme-new] [Bug 10737] New: pktgen procfs problem
Date: Sun, 18 May 2008 15:24:25 +0200
Message-ID: <48302E09.8080701@trash.net>
References: <bug-10737-10286@http.bugzilla.kernel.org/>	<20080517141036.d8f3c768.akpm@linux-foundation.org>	<482F88DE.8090508@trash.net> <20080517215641.acb94677.akpm@linux-foundation.org> <48301BE0.9040907@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	devzero@web.de, Robert Olsson <robert.olsson@its.uu.se>,
	"Denis V. Lunev" <den@openvz.org>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:36876 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752996AbYERNY1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 May 2008 09:24:27 -0400
In-Reply-To: <48301BE0.9040907@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy wrote:
> Andrew Morton wrote:
>> On Sun, 18 May 2008 03:39:42 +0200 Patrick McHardy <kaber@trash.net> 
>> wrote:
>>
>>  
>>> I've been looking into the same problem, without much success so
>>> far. The problem appears to affect any /proc/net file, but not
>>> files outside of /proc/net, so I'm guessing its net-ns related.
>>> A testcase found by Ben Greear is opening the file multiple times:
>>>
>>> # /tmp/open /proc/net/kpktgen_0
>>>
>>> => refcnt goes to 1
>>>
>>> ^C
>>>
>>> => refcnt goes to 0
>>>
>>> Without ^C and opening the file a second time:
>>>
>>> # /tmp/open /proc/net/kpktgen_0
>>>
>>> => refcnt goes to 2 (sometimes also 11)
>>>
>>> ^C
>>>
>>> => refcnt stays at previous value.
>>>
>>> The refcnt even leaks if the file can't be successfully opened,
>>> for example because of lacking permissions.
>>>     
>>
>> urgh.  Is any of this known to be post-2.6.25?
>>   
> 
> 2.6.25 is also affected. I don't know about earlier kernels.

Some more information: the problem seems to occur only if
the file is opened by two different processes.

I'm starting a bisection now.
