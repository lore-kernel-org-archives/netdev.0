From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: oops in pskb_expand_head - 3.11.6
Date: Mon, 18 Nov 2013 10:24:36 +0100
Message-ID: <20131118092436.GA3743@minipsycho.orion>
References: <20131116231615.GA24327@marquez.int.rhx>
 <20131116234223.GG16541@order.stressinduktion.org>
 <20131117111150.GC24327@marquez.int.rhx>
 <20131117191810.GH16541@order.stressinduktion.org>
 <20131118091922.GB11185@marquez.int.rhx>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Michele Baldessari <michele@acksyn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f179.google.com ([209.85.215.179]:47537 "EHLO
	mail-ea0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751082Ab3KRJYk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Nov 2013 04:24:40 -0500
Received: by mail-ea0-f179.google.com with SMTP id r15so2226324ead.24
        for <netdev@vger.kernel.org>; Mon, 18 Nov 2013 01:24:39 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20131118091922.GB11185@marquez.int.rhx>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Nov 18, 2013 at 10:19:22AM CET, michele@acksyn.org wrote:
>Hi Hannes,
>
>On Sun, Nov 17, 2013 at 08:18:10PM +0100, Hannes Frederic Sowa wrote:
>> On Sun, Nov 17, 2013 at 11:11:50AM +0000, Michele Baldessari wrote:
>> > Hi Hannes,
>> > 
>> > On Sun, Nov 17, 2013 at 12:42:23AM +0100, Hannes Frederic Sowa wrote:
>> > > On Sat, Nov 16, 2013 at 11:16:15PM +0000, Michele Baldessari wrote:
>> > > > Two oops like the following were reported in Fedora 19 - kernel 3.11.6:
>> > > > https://bugzilla.redhat.com/show_bug.cgi?id=1015905
>> > > 
>> > > I have not followed that issue that closely, but could you try linus tree
>> > > or net-next?
>> > > 
>> > > Maybe those two patches improve the situation:
>> > > https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=9037c3579a277f3a23ba476664629fda8c35f7c4
>> > > https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=6aafeef03b9d9ecf255f3a80ed85ee070260e1ae
>> > > 
>> > indeed a current kernel seems to fix the crash (according to the
>> > reporters). I'll see if I manage to bisect exactly.
>> 
>> Great, if you confirm this we can ask David if he adds the commits to the
>> -stable queue.
>
>I can confirm that 6aafeef03b9d9ecf255f3a80ed85ee070260e1ae "netfilter:
>push reasm skb through instead of original frag skbs" fixes the oops
>mentioned in this thread. I've applied it to a 3.11.8 kernel and it
>fixed the crash. I had to slightly tweak it as it does not apply 100%
>cleanly due to 795aa6ef6a1aba99050735eadd0c2341b789b53b " netfilter:
>pass hook ops to hookfn". 
>
>So definitely -stable material.
>
>Not sure if you also want to add 9037c3579a277f3a23ba476664629fda8c35f7c4 
>"ip6_output: fragment outgoing reassembled skb properly". It did not
>have any impact in this particular scenario.

It goes hand in hand with 6aafeef03b9d9ecf255f3a80ed85ee070260e1ae.
Without 9037c3579a277f3a23ba476664629fda8c35f7c4 skbs that reasm len is
< MTU would not get fragmented which is not desired.


>
>Thanks again,
>Michele
>-- 
>Michele Baldessari            <michele@acksyn.org>
>C2A5 9DA3 9961 4FFB E01B  D0BC DDD4 DCCB 7515 5C6D
