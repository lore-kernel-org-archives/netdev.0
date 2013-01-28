From: Martin Mokrejs <mmokrejs@fold.natur.cuni.cz>
Subject: Re: [PATCH] SCTP: Free the per-net sysctl table on net exit. v2
Date: Mon, 28 Jan 2013 22:17:09 +0100
Message-ID: <5106EAD5.6000703@fold.natur.cuni.cz>
References: <20130127.193511.2294954038548420781.davem@davemloft.net> <87libe3w69.fsf@xmission.com> <87obgayoo8.fsf_-_@xmission.com> <20130128.001125.1697434398997976656.davem@davemloft.net> <510637D8.9000305@fold.natur.cuni.cz> <877gmxtim7.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, vyasevich@gmail.com,
	netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fold.natur.cuni.cz ([195.113.57.32]:33007 "HELO
	fold.natur.cuni.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751155Ab3A1VRM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jan 2013 16:17:12 -0500
In-Reply-To: <877gmxtim7.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

Eric W. Biederman wrote:
> Martin Mokrejs <mmokrejs@fold.natur.cuni.cz> writes:
> 
>> David Miller wrote:
>>> From: ebiederm@xmission.com (Eric W. Biederman)
>>> Date: Sun, 27 Jan 2013 19:25:11 -0800
>>>
>>>> The typo is fixed in the patch this time in addition to my test
>>>> tree.
>>>
>>> Applied, thanks for fixing this up Eric.
>>
>> I did check now how come that I patched my 3.7.4 on Jan 24. Looks like
>> -head or -next has different namings. For me, the original patch applied
>> fine. So far I haven't hit the memleak although it happened only once to me
>> before the patch.
> 
> The problem isn't that the patch doesn't apply the problem is that the
> patch did not build.  The naming has not changed in the git history.
> 
>> But probably I can confirm say Tested-by:.
>>
>> #
>> -rw-r--r-- 1 root root  8435 Jan 24 17:12 /usr/src/linux-3.7.4/net/sctp/sysctl.c
>> -rw-rw-r-- 1 root root  8347 Jan 21 20:45 /usr/src/linux-3.7.4/net/sctp/sysctl.c.orig
>> # ls -la /usr/src/linux-3.7.4/net/sctp/sysctl.o
>> -rw-r--r-- 1 root root 246144 Jan 21 22:37 /usr/src/linux-3.7.4/net/sctp/sysctl.o
>> # ls -la /usr/src/linux-3.7.4/arch/x86/boot/bzImage 
>> -rw-r--r-- 1 root root 3794592 Jan 21 22:45 /usr/src/linux-3.7.4/arch/x86/boot/bzImage
>> #
> 
> It doesn't look look like you rebuilt anything after you applied the
> changes to net/sctp/sysctl.c.  sysctl.o and bzImage are both 3 days older.

Ah, I must have been really blind. Thanks for pointing that out. I should
really start to do:

make bzImage && make modules && make modules_install && cp arch/x86_64/boot/bzImage /boot/vmlinuz-$ver

echo "silly me, make(1) did not delete the old bzImage"


So I haven't tested the patch yet. doh. Provided I am running 3 days without reproducing
the original memleak on an unpatched kernel I doubt I can easily prove it after a reboot.
:( Will probably stay untested. But compiles fine here. ;-)


Thanks,
Martin
