From: Greg KH <greg@kroah.com>
Subject: Re: [stable] [BUG] net: fix /proc/net/snmp as memory corruptor
Date: Sat, 15 Nov 2008 10:43:09 -0800
Message-ID: <20081115184309.GA24983@kroah.com>
References: <491D07E0.9010903@cosmosbay.com> <20081115051015.GB26468@kroah.com> <491E5D4D.1080800@cosmosbay.com> <20081115060237.GA3910@kroah.com> <491E8A47.1090007@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: stable@kernel.org, "David S. Miller" <davem@davemloft.net>,
	netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kroah.org ([198.145.64.141]:56584 "EHLO coco.kroah.org"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751734AbYKOSqU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Nov 2008 13:46:20 -0500
Content-Disposition: inline
In-Reply-To: <491E8A47.1090007@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 15, 2008 at 09:37:27AM +0100, Eric Dumazet wrote:
> Greg KH a =E9crit :
>> On Sat, Nov 15, 2008 at 06:25:33AM +0100, Eric Dumazet wrote:
>>> Greg KH a =E9crit :
>>>> On Fri, Nov 14, 2008 at 06:08:48AM +0100, Eric Dumazet wrote:
>>>>> Hello Greg
>>>>>
>>>>> A patch was submited about /proc/net/snmp being a memory corrupto=
r and=20
>>>>> not SMP safe
>>>>>
>>>>> (commit b971e7ac834e9f4bda96d5a96ae9abccd01c1dd8)
>>>>>
>>>>> These bugs are present on 2.6.26 & 2.6.27.
>>>> I looking at this, it doesn't seem to apply at all to the .27 tree=
=2E  If
>>>> David doesn't object, care to backport it there and send it to
>>>> stable@kernel.org?
>>> Strange... I just tried to apply patch on top of a fresh linux-2.6.=
27.6=20
>>> tree and got no error
>>>
>>> # patch -p1 < /tmp/icmp_snmp.patch
>>> patching file net/ipv4/proc.c
>>> #
>> I've attached the patch I tried to apply below.  It fails with:
>> 	$ patch -p1 --dry-run <=20
>> ../net-fix-proc-net-snmp-as-memory-corruptor.patch 	patching file=20
>> net/ipv4/proc.c
>> 	Hunk #1 FAILED at 237.
>> 	1 out of 1 hunk FAILED -- saving rejects to file net/ipv4/proc.c.re=
j
>> Any thoughts?
>> thanks,
>> greg k-h
>
> Yes, you lost all the '\' character in "\n" sequences... Also one mis=
sing=20
> ":" at the end of one line
>
> I dont know how you did it :)

Oh crap, that's my fault.  I hate bash at times, I'm using a script to
copy changesets and format them in the way that works for the stable
tree.  I need to switch it to perl so these things don't happen :(

In looking closer, I also messed up on some other patches in this -rc1,
I need to redo the whole thing.  Ugh.

Thanks for pointing this out, I'll fix it up.

greg k-h
