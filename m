From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: Flows! Offload them.
Date: Thu, 26 Feb 2015 10:16:26 -0800
Message-ID: <CAE4R7bC2uqOaiRR9Q=hEzD4gDKJ4cHQQLwYYYwHa_FVS58t1Yg@mail.gmail.com>
References: <20150226074214.GF2074@nanopsycho.orion>
	<20150226083758.GA15139@vergenet.net>
	<20150226091628.GA4059@nanopsycho.orion>
	<CA+mtBx-sVMNFng_=DcM5mJTbzrRNsFhTvC8YxvjxcqEXwDcWWw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jiri Pirko <jiri@resnulli.us>,
	Simon Horman <simon.horman@netronome.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Neil Horman <nhorman@tuxdriver.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Thomas Graf <tgraf@suug.ch>,
	Daniel Borkmann <dborkman@redhat.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Jesse Gross <jesse@nicira.com>, jpettit@nicira.com,
	Joe Stringer <joestringer@nicira.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	John Linville <linville@tuxdriver.com>,
	Shrijeet Mukherjee <shrijeet@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Benjamin LaHaise <bcrl@kvack.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f51.google.com ([209.85.192.51]:45201 "EHLO
	mail-qg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753420AbbBZSQ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 13:16:27 -0500
Received: by mail-qg0-f51.google.com with SMTP id z60so9972342qgd.10
        for <netdev@vger.kernel.org>; Thu, 26 Feb 2015 10:16:26 -0800 (PST)
In-Reply-To: <CA+mtBx-sVMNFng_=DcM5mJTbzrRNsFhTvC8YxvjxcqEXwDcWWw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 26, 2015 at 8:04 AM, Tom Herbert <therbert@google.com> wrote:

> Sorry if I'm asking dumb questions, but this is about where I usually
> start to get lost in these discussions ;-). Is the aim of switch
> offload to offload OVS or kernel functions of routing, iptables, tc,
> etc.?

Both, which is why it's hard to follow, and there are active efforts
on both fronts.  What has stuck so far with switchdev is offloading
kernel functions, such as L2 bridging to existing switch chips (real
(DSA) or fake (rocker)).  WIP on extended that to L3 and maybe a
subset of nftables.  So far, the kernel is the "application", and
we're offloading (sorry, overloaded term, but I can't think of an
alternative) the kernel fwd data paths to capable hardware.  But there
are "impedance" mismatches between what we can do today in the kernel
and fixed hardware.  On the other front we have offloading OVS, or
more in more general terms, programming the switch from some other
"application", local or remote using the proposed flow api or tc or
some combination.  Maybe these two fronts merge down the road where
the kernel is just another application using the flow api.  Grand
unification theory?


> These are very different I believe. As far as I can tell OVS
> model of "flows" (like Openflow) is currently incompatible with the
> rest of the kernel.
> So if the plan is convert OVS datapath to TC does
> that mean introducing that model into core kernel?
