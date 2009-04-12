From: david@lang.hm
Subject: Re: iptables very slow after commit
 784544739a25c30637397ace5489eeb6e15d7d49
Date: Sat, 11 Apr 2009 17:54:41 -0700 (PDT)
Message-ID: <alpine.DEB.1.10.0904111751430.28893@asgard.lang.hm>
References: <alpine.LFD.2.00.0904101828490.4583@localhost.localdomain>  <20090411041533.GB6822@linux.vnet.ibm.com>  <alpine.LSU.2.00.0904110657410.26485@fbirervta.pbzchgretzou.qr>  <20090410.230016.176733137.davem@davemloft.net>
 <f73f7ab80904111112n7c95d06ei32eb1f081842ae41@mail.gmail.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="680960-131394981-1239497682=:28893"
Cc: David Miller <davem@davemloft.net>, jengelh@medozas.de,
	paulmck@linux.vnet.ibm.com, torvalds@linux-foundation.org,
	mingo@elte.hu, laijs@cn.fujitsu.com, shemminger@vyatta.com,
	jeff.chua.linux@gmail.com, dada1@cosmosbay.com, kaber@trash.net,
	r000n@r000n.net, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Kyle Moffett <kyle@moffetthome.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <f73f7ab80904111112n7c95d06ei32eb1f081842ae41@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--680960-131394981-1239497682=:28893
Content-Type: TEXT/PLAIN; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8BIT

On Sat, 11 Apr 2009, Kyle Moffett wrote:

> On Sat, Apr 11, 2009 at 2:00 AM, David Miller <davem@davemloft.net> wrote:
>> From: Jan Engelhardt <jengelh@medozas.de>
>> Date: Sat, 11 Apr 2009 07:14:50 +0200 (CEST)
>>
>>> The fact that `iptables -A` is called a hundred times means you are
>>> doing 100 table replacements -- instead of one. And calling
>>> synchronize_net at least a 100 times.
>>>
>>> "Wanna use iptables-restore?"
>>
>> I want to derail this line of thinking as fast as possible.
>>
>> This is not an acceptable response to this problem.  We made something
>> fundamentally slower by several orders of magnitude.
>>
>> Therefore, saying "Don't insert your firewall rules like that." is not
>> a valid response for this regression.
>>
>> We really have to fix it or revert.
>
> Let me start by saying that I agree that for most systems this patch
> provided a bad performance tradeoff that needs to get fixed.
>
> On the other hand I have certain systems where I would much rather
> reduce the per-packet load by a few percent...  even if it increases
> the effort to load a new ruleset by many orders of magnitude!!!  Quite
> simply the boxes only reboot a few times a year but in-between times
> they forward many terabytes of low-latency network traffic.
>
> So... to play devils advocate:
>
> Almost all of the standard firewall tools (such as shorewall, etc) are
> already using iptables-restore command to load firewall rules,
> primarily because using separate iptables commands was *already* way
> too slow.  There's also the serious race-condition of doing a firewall
> restart that way where you only have half your rules loaded for a bit.
> The "iptables" command is fine for fiddling around with the command
> line and making minor tweaks, but it simply doesn't cut it for
> large-scale rules.

what are the userspace level tools that I am supposed to use in place of 
my current process? (which is to have a script that 1. stops traffic, 2. 
executes the iptables commands to create the rules that I want, then 3. 
enables traffic)

iptables-restore only works if you are actually restoring the old set of 
rules. if you need to change the rules that doesn't work.

David Lang

> I remember when switching from a shell-based shorewall to a perl-based
> shorewall.  The time to build my rule lists with the perl-based
> version was about 20% of what it had been, but the time to load the
> rules into the kernel with iptables-restore was easily 2% or perhaps
> less.
>
> Finally, if you really are loading a couple hundred IPs into a linear
> ruleset, you're adding a fair amount of packet latency to each and
> every packet that goes through totally independent of iptables load
> time.  It would be much better to use ipsets (or similar) because they
> load all of the IP ranges into an appropriate tree datastructure with
> O(small-constant * log(N) + large-constant * 1) lookup instead of
> O(large-constant * N).
>
> Cheers,
> Kyle Moffett
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>
--680960-131394981-1239497682=:28893--
