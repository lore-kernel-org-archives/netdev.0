From: Thomas Graf <tgraf@suug.ch>
Subject: Re: Flows! Offload them.
Date: Fri, 27 Feb 2015 08:41:41 +0000
Message-ID: <20150227084141.GA17240@casper.infradead.org>
References: <20150226074214.GF2074@nanopsycho.orion>
 <20150226083758.GA15139@vergenet.net>
 <20150226091628.GA4059@nanopsycho.orion>
 <20150226133326.GC23050@casper.infradead.org>
 <54EF3A78.9020507@intel.com>
 <20150226201635.GA366@hmsreliant.think-freely.org>
 <20150226215255.GA15033@penelope.isobedori.kobe.vergenet.net>
 <20150227012239.GB8847@neilslaptop.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Simon Horman <simon.horman@netronome.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
	davem@davemloft.net, andy@greyhouse.net, dborkman@redhat.com,
	ogerlitz@mellanox.com, jesse@nicira.com, jpettit@nicira.com,
	joestringer@nicira.com, jhs@mojatatu.com, sfeldma@gmail.com,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, shrijeet@gmail.com,
	gospo@cumulusnetworks.com, bcrl@kvack.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:33621 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753201AbbB0Ilq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2015 03:41:46 -0500
Content-Disposition: inline
In-Reply-To: <20150227012239.GB8847@neilslaptop.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/26/15 at 08:22pm, Neil Horman wrote:
> Yes, exactly that, for the general traditional networking use case, that is
> exactly what we want, to opportunistically move traffic faster with less load on
> the cpu.  We don't nominally care what traffic is offloaded, as long as the
> hardware does a better job than just software alone.  If we get an occasional
> miss and have to do stuff in software, so be it.

Blind random offload of some packets is better than nothing but knowing
and having control over which packets are offloaded is essential. You
typically don't want to randomly give one flow priority over another ;-)
Some software CPUs might not be able to handle the load. I know what
you mean though and as long as we allow to disable and overwrite this
behaviour we are good.

> So, this is a case in which I think John F.'s low level flow API is more well
> suited.  OVS has implemented a user space dataplane that circumvents alot of the
> kernel mechanisms for traffic forwarding.  For that sort of application, the
> traditional kernel offload "objects" aren't really appropriate.  Instead, OVS
> can use the low level flow API to construct its own custom offload pipeline
> using whatever rules and policies that it wants.

Maybe I'm misunderstanding your statement here but I think it's essential
that the kernel is able to handle whatever we program in hardware even
if the hardware tables look differrent than the software tables, no matter
whether the configuration occurs through OVS or not. A punt to software
should always work even if it does not happen. So while I believe that
OVS needs more control over the hardware than available through the
datapath cache it must program both the hardware and software in parallel
even though the building blocks for doing so might look different.

> Of course, using the low level flow API is incompatible with the in-kernel
> object offload idea that I'm proposing, but I see the two as able to co-exist,
> much like firewalld co-exists with iptables.  You can use both, but you have to
> be aware that using the lower layer interface might break the others higher
> level oeprations.  And if that happens, its on you to manage it.

I think this does not have to be mutually exclusive. An example would
be a well defined egress qdisc which is offloaded into it's own table.
If OVS is aware of the table it can make use of it while configuring
that table through the regular qdisc software API.
