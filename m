From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v1 1/6] net: Generalize udp based tunnel offload
Date: Wed, 09 Dec 2015 17:21:28 -0500 (EST)
Message-ID: <20151209.172128.2004885848439372720.davem@davemloft.net>
References: <20151209125857.GA9900@pox.localdomain>
	<20151209173842.GA18097@ast-mbp.thefacebook.com>
	<20151209220339.GD11201@pox.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, jhs@mojatatu.com,
	john.fastabend@gmail.com, tom@herbertland.com,
	hannes@stressinduktion.org, linville@tuxdriver.com,
	jesse@kernel.org, anjali.singhai@intel.com, netdev@vger.kernel.org,
	kiran.patil@intel.com
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41365 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751422AbbLIWVc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2015 17:21:32 -0500
In-Reply-To: <20151209220339.GD11201@pox.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Wed, 9 Dec 2015 23:03:39 +0100

> On 12/09/15 at 09:38am, Alexei Starovoitov wrote:
>> On Wed, Dec 09, 2015 at 01:58:57PM +0100, Thomas Graf wrote:
>> > 
>> > So if the goal is to make the intent available to the hardware in
>> > a format which both the kernel and the hardware can draw the same
>> > conclusions from, wouldn't something like P4 + BPF derived from P4
>> > be a possibly better fit? There is discussion on stateful P4
>> > processing now.
>> 
>> p4 is a high level language and absolutely not suitable for such purpose.
>> bpf as intermediate representation can be generated from p4 or C or other
>> language. There is room to innovate in the language definition on top
>> and in HW design at the bottom. That's the most flexible model.
> 
> If you don't want to discuss it, no problem. But stating that P4
> is a high level language (not sure what this means exactly since
> we exactly _want_ an abstraction away from hardware) and that it's
> not suitable for this purpose is just wrong. P4 has been created
> exactly for the purpose of expressing how a packet should be
> processed by a forwarding element independent of specific hardware.

Just because it was supposeduly designed for this purpose, doesn't
mean it's the most appropriate intermediate language between what
the kernel wants hardware to do and what actually has to happen for
the hardware to do that.

BPF is so much more universal and can cover everything we'd want
hardware to perform, and then some.

Plus it's everywhere in the kernel already, has a full validation and
test suite, full LLVM backend, plus JITs for several prominent
architectures with more on the way.

It is clearly the most appropriate middle layer representation.

The fact that BPF could be generated from any P4 program, yet the
reverse is not true, tells me everything I need to know.

I'm sorry if you have either a mental or a time invenstment in P4, but
I really don't see it as really suitable for this.
