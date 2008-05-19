From: Ben Greear <greearb@candelatech.com>
Subject: Re: [Bugme-new] [Bug 10737] New: pktgen procfs problem
Date: Mon, 19 May 2008 15:19:37 -0700
Message-ID: <4831FCF9.1090905@candelatech.com>
References: <bug-10737-10286@http.bugzilla.kernel.org/>	<20080517141036.d8f3c768.akpm@linux-foundation.org>	<482F88DE.8090508@trash.net>	<20080517215641.acb94677.akpm@linux-foundation.org>	<48301BE0.9040907@trash.net> <48302E09.8080701@trash.net>	<48304BB5.7090805@trash.net> <m11w3y7zbl.fsf@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	devzero@web.de, Robert Olsson <robert.olsson@its.uu.se>,
	"Denis V. Lunev" <den@openvz.org>,
	Pavel Emelyanov <xemul@openvz.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([66.165.47.212]:55018 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751187AbYESWUi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 May 2008 18:20:38 -0400
In-Reply-To: <m11w3y7zbl.fsf@frodo.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric W. Biederman wrote:
> Patrick McHardy <kaber@trash.net> writes:
> 
>> Patrick McHardy wrote:
>>>>>> I've been looking into the same problem, without much success so
>>>>>> far. The problem appears to affect any /proc/net file, but not
>>>>>> files outside of /proc/net, so I'm guessing its net-ns related.
>>>>>> A testcase found by Ben Greear is opening the file multiple times:
>>>>>>
>>>>>> # /tmp/open /proc/net/kpktgen_0
>>>>>>
>>>>>> => refcnt goes to 1
>>>>>>
>>>>>> ^C
>>>>>>
>>>>>> => refcnt goes to 0
>>>>>>
>>>>>> Without ^C and opening the file a second time:
>>>>>>
>>>>>> # /tmp/open /proc/net/kpktgen_0
>>>>>>
>>>>>> => refcnt goes to 2 (sometimes also 11)
>>>>>>
>>>>>> ^C
>>>>>>
>>>>>> => refcnt stays at previous value.
>>>>>>
>>>>>> The refcnt even leaks if the file can't be successfully opened,
>>>>>> for example because of lacking permissions.
> 
> How are you reading the refcount on kpktgen_0? Just a printk in the
> kernel code?
> 
>>> Some more information: the problem seems to occur only if
>>> the file is opened by two different processes.
>>>
>>> I'm starting a bisection now.
>>
>> git-bisect identified e9720acd ([NET]: Make /proc/net a symlink
>> on /proc/self/net (v3)) as the guilty commit. I couldn't find
>> the problem in that commit, so someone with a better understanding
>> of how this is supposed to work should look into it.
> 
> To recap:
> - The problem is that we get complaints from remove_proc_entry
>   on unload of the pktgen module.
> 
> - The problem appears to only happen when multiple processes open the file.
> 
> - The problem only appears after we moved /proc/net into /proc/<pid>/net

Just to be clear, the problem I saw with too many refs would not even let
me remove a module.  They may be the same root problem, but not necessarily.

I also saw the problem on multiple modules with proc/net/ file systems,
not just pktgen.

The part about multiple processes opening the file is definitely true
with my bug report, but based on email I saw, I'm not sure it is true for
the remove_proc_entry problem reported by someone else.

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

