From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: Flows! Offload them.
Date: Mon, 2 Mar 2015 08:54:06 -0800
Message-ID: <CAE4R7bCQrHqgyBkEuEpoZnn2npeuBrGUG60Zwpg8RBB20JwqeA@mail.gmail.com>
References: <20150226074214.GF2074@nanopsycho.orion>
	<20150226083758.GA15139@vergenet.net>
	<20150226091628.GA4059@nanopsycho.orion>
	<20150226133326.GC23050@casper.infradead.org>
	<54EF3A78.9020507@intel.com>
	<20150226201635.GA366@hmsreliant.think-freely.org>
	<20150226215255.GA15033@penelope.isobedori.kobe.vergenet.net>
	<20150227012239.GB8847@neilslaptop.think-freely.org>
	<CA+mtBx_E5D-ryU=etdKf+7bnYwqHKJbqDc22A5=ypWCL5Z_E1g@mail.gmail.com>
	<20150302134946.GB7971@gospo.home.greyhouse.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Tom Herbert <therbert@google.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Simon Horman <simon.horman@netronome.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Thomas Graf <tgraf@suug.ch>, Jiri Pirko <jiri@resnulli.us>,
	Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Andy Gospodarek <andy@greyhouse.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Jesse Gross <jesse@nicira.com>, jpettit@nicira.com,
	Joe Stringer <joestringer@nicira.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	John Linville <linville@tuxdriver.com>,
	Shrijeet Mukherjee <shrijeet@gmail.com>,
	Benjamin LaHaise <bcrl@kvack.org>
To: Andy Gospodarek <gospo@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f46.google.com ([209.85.216.46]:35253 "EHLO
	mail-qa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754250AbbCBQyH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2015 11:54:07 -0500
Received: by mail-qa0-f46.google.com with SMTP id n4so23780932qaq.5
        for <netdev@vger.kernel.org>; Mon, 02 Mar 2015 08:54:06 -0800 (PST)
In-Reply-To: <20150302134946.GB7971@gospo.home.greyhouse.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 2, 2015 at 5:49 AM, Andy Gospodarek
<gospo@cumulusnetworks.com> wrote:
> On Thu, Feb 26, 2015 at 05:52:16PM -0800, Tom Herbert wrote:
>> On Thu, Feb 26, 2015 at 5:22 PM, Neil Horman <nhorman@tuxdriver.com> wrote:
> [...]
>> > Yes, exactly that, for the general traditional networking use case, that is
>> > exactly what we want, to opportunistically move traffic faster with less load on
>> > the cpu.  We don't nominally care what traffic is offloaded, as long as the
>> > hardware does a better job than just software alone.  If we get an occasional
>> > miss and have to do stuff in software, so be it.
>> >
>> +1 on an in kernel "Network Resource Manager". This also came up in
>> Sunil's plan to configure RPS affinities from a driver so I'm taking
>> liberty by generalizing the concept :-).
>
> I agree completely that there is a need for what you both describe.  Not
> only to handle what items to offload for users looking for that level
> of granularity, but also to allow driver implementers to decide if their
> hardware/driver implementation may allow for async write of data to
> hardware tables, and any other implementation specific detail they may
> want to provide.

Can you elaborate on "allow for async write of data to hardware
tables"?  Is this the trampoline model where user's request goes to
the kernel, and then back to user-space, and finally to the hardware
via an user-space SDK?  I think we should exclude that model from
discussions about resource management.  With the recent L2/L3 offload
work, I'm advocating a synchronous call path from user to kernel to
hardware so we can return a actionable result code, and put the burden
of resource management in user-space, not in the kernel.

-scott
