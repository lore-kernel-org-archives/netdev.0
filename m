From: Nick Warne <nick@linicks.net>
Subject: Re: [PATCH] net/core/sysctl_net_core.c  unused variable
Date: Sun, 06 Sep 2015 17:08:36 +0100
Message-ID: <55EC6504.7060800@linicks.net>
References: <55EC4A03.905@linicks.net>	 <1441551148.28194.40.camel@perches.com> <55EC58DF.6020501@linicks.net>	 <1441553310.28194.44.camel@perches.com> <55EC5D6B.3030402@linicks.net> <1441554714.28194.49.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Alexey Kodanev <alexey.kodanev@oracle.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 78-32-181-23.static.enta.net ([78.32.181.23]:50649 "EHLO
	mail.linicks.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750871AbbIFQIi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Sep 2015 12:08:38 -0400
In-Reply-To: <1441554714.28194.49.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 06/09/15 16:51, Joe Perches wrote:
> On Sun, 2015-09-06 at 16:36 +0100, Nick Warne wrote:
>> On 06/09/15 16:28, Joe Perches wrote:
>> > On Sun, 2015-09-06 at 16:16 +0100, Nick Warne wrote:
>> >> On 06/09/15 15:52, Joe Perches wrote:
>> >> > On Sun, 2015-09-06 at 15:13 +0100, Nick Warne wrote:
>> >> >> gcc version 4.8.2 (GCC) warns that 'static int one = 1;' is declared but
>> >> >> not used in file net/core/sysctl_net_core.c.
>> >> >
>> >> > Only when CONFIG_NET isn't set.
>> >>
>> >> CONFIG_NET=y
>> >>
>> >> Peculiar indeed.
>> >>
>> >> >> Reading the file, that is
>> >> >> the case.  Attached is a patch to remove it.
>> >> >
>> >> > $ git grep -w -n one net/core/sysctl_net_core.c
>> >> > net/core/sysctl_net_core.c:26:static int one = 1;
>> >> > net/core/sysctl_net_core.c:332:         .extra2         = &one
>> >> >
>> >> >> Signed-off-by:  Nick Warne <nick@linicks.net>
>> >> >
>> >> > Please use grep to augment reading.
>> >>
>> >> grep -w -n one net/core/sysctl_net_core.c
>> >> 26:static int one = 1;
>> >>
>> >> ?
>> >>
>> >> I just don't have the &one.
>> >>
>> >> I am confused now.
>> >
>> > What source tree are you using?
>>
>> Latest longterm 3.18.21
>
> OK, it's important to mention that otherwise the
> assumption would be a git tree like net or net-next.
>
>> > What changes in what branch exist?
>>
>> I am not using git (if that is what you mean by 'branches') - just
>> tarballs from kernel.org
>
> (OK, using git and linux-stable)
>
> $ git grep -w -n one v3.18.21 -- net/core/sysctl_net_core.c
> v3.18.21:net/core/sysctl_net_core.c:26:static int one = 1;
>
> And the responsible commit:
>
> commit c48cf4f27d4555a455c3fef71137bd0fc44d1656
> ("net: sysctl_net_core: check SNDBUF and RCVBUF for min length")

Ah, OK. GCC was right - just the variable declaration was overlooked to 
be removed too.

http://git.kernel.org/cgit/linux/kernel/git/stable/linux-stable.git/commit/?id=c48cf4f27d4555a455c3fef71137bd0fc44d1656

My patch was right then (but wrong) :)

Thanks Joe,

Nick

-- 
Gosh that takes me back... or is it forward?  That's the trouble with
time travel, you never can tell."
		-- Doctor Who "Androids of Tara"
