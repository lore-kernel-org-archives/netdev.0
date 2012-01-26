From: Glauber Costa <glommer@parallels.com>
Subject: Re: linux-next: Tree for Jan 25 (net/sock.h, jump_label, memcg)
Date: Fri, 27 Jan 2012 00:31:13 +0400
Message-ID: <4F21B811.90904@parallels.com>
References: <20120125141938.c1a9460d56948e1c7b26d3f8@canb.auug.org.au> <4F2052DB.4060602@xenotime.net> <CAMuHMdWp1wEHqPXNs+kaMYpomJnfbZPJjRk5GVFCuCL4Q5zK7g@mail.gmail.com> <20120126.134333.31948964659222759.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <geert@linux-m68k.org>, <rdunlap@xenotime.net>,
	<sfr@canb.auug.org.au>, <linux-next@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <gleb@redhat.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20120126.134333.31948964659222759.davem@davemloft.net>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/26/2012 10:43 PM, David Miller wrote:
> From: Geert Uytterhoeven<geert@linux-m68k.org>
> Date: Thu, 26 Jan 2012 18:18:28 +0100
>
>> On Wed, Jan 25, 2012 at 20:07, Randy Dunlap<rdunlap@xenotime.net>  wrote:
>>> back to net/sock.h and jump_label:
>>>
>>> (on i386:)
>>>
>>> /next/linux-next-20120125/include/net/sock.h:953:2: error: implicit declaration of function 'static_branch'
>>> /next/linux-next-20120125/include/linux/jump_label.h:43:29: error: conflicting types for 'static_branch'
>>>
>>> Full randconfig file is attached.
>>
>> Without having to add randomness, also in m68k/allmodconfig, now in Linus'
>> tree :-(
>> http://kisskb.ellerman.id.au/kisskb/buildresult/5491860/
>
> Glauber are you actually going to fix this or are you going to ignore
> this bug report for another couple days?!?!
Dave,

I am going to work on it right now, with no further delays, as I've been 
doing with all the reports I've got. I didn't receive any report
about this one for some reason, and that's why I didn't say anything.
So thanks for nagging.

>
> Frankly, I'm so sick and tired of all of these socket mem cgroup
> regressions, this is way out of control and every "fix" seems to add
> more build or runtime regressions.
>
> Glauber, this has to stabilize soon or I will revert every single one
> of your changes, and it will take a nuclear war and a multi-month
> audit of your code to get those changes into the tree again.

So for the normal scenarios with my code disabled, aside for one problem 
in day1, all of the failures were build problems.

To be quite honest, the interactions between configs are being quite 
"funny", and spanning more problems than I anticipated.

What I am doing here, is building the patches against a couple of 
randconfigs, and some more targeted ones before I send them to you.

If you have any other advise on how to handle this, I'd be happy to take 
them.

On the specifics of this bug, I verified this config compiles okay in 
your tree + my patches at the day I last sent them. I also verified it 
breaks on the tree today.

The reason seems to be that some other patch tweaked with the header 
files in an unrelated patch, and the static_branch definition that was 
getting to us in sock.h, is no longer getting there.

Including it explicitly fixes it here. I will again pass through a 
battery of randconfigs on my own, and send you a fix.

Sorry again for the trouble.
