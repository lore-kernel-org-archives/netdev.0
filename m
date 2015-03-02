From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: Flows! Offload them.
Date: Mon, 2 Mar 2015 17:43:35 -0500
Message-ID: <20150302224335.GA14057@gospo.home.greyhouse.net>
References: <20150226133326.GC23050@casper.infradead.org>
 <54EF3A78.9020507@intel.com>
 <20150226201635.GA366@hmsreliant.think-freely.org>
 <20150226215255.GA15033@penelope.isobedori.kobe.vergenet.net>
 <20150227012239.GB8847@neilslaptop.think-freely.org>
 <CA+mtBx_E5D-ryU=etdKf+7bnYwqHKJbqDc22A5=ypWCL5Z_E1g@mail.gmail.com>
 <20150302134946.GB7971@gospo.home.greyhouse.net>
 <CAE4R7bCQrHqgyBkEuEpoZnn2npeuBrGUG60Zwpg8RBB20JwqeA@mail.gmail.com>
 <CAGpadYEC3-5AdkOG66q0vX+HM0c6EU-C0ZT=sKGe7rZRHsYYKg@mail.gmail.com>
 <CAE4R7bAueaSn7Z+Wcipf7UYQ57GteomTJDM8Ohn_-KFu5zw0sw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Shrijeet Mukherjee <shrijeet@gmail.com>,
	Tom Herbert <therbert@google.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Simon Horman <simon.horman@netronome.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Thomas Graf <tgraf@suug.ch>, Jiri Pirko <jiri@resnulli.us>,
	Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Andy Gospodarek <andy@greyhouse.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Jesse Gross <jesse@nicira.com>,
	"jpettit@nicira.com" <jpettit@nicira.com>,
	Joe Stringer <joestringer@nicira.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	John Linville <linville@tuxdriver.com>,
	Benjamin LaHaise <bcrl@kvack.org>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f45.google.com ([209.85.216.45]:38477 "EHLO
	mail-qa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753846AbbCBWnx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2015 17:43:53 -0500
Received: by mail-qa0-f45.google.com with SMTP id j7so25419097qaq.4
        for <netdev@vger.kernel.org>; Mon, 02 Mar 2015 14:43:52 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CAE4R7bAueaSn7Z+Wcipf7UYQ57GteomTJDM8Ohn_-KFu5zw0sw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 02, 2015 at 02:13:35PM -0800, Scott Feldman wrote:
> On Mon, Mar 2, 2015 at 10:31 AM, Shrijeet Mukherjee <shrijeet@gmail.com> wrote:
> >>
> >> Can you elaborate on "allow for async write of data to hardware
> >> tables"?  Is this the trampoline model where user's request goes to
> >> the kernel, and then back to user-space, and finally to the hardware
> >> via an user-space SDK?  I think we should exclude that model from
> >> discussions about resource management.  With the recent L2/L3 offload
> >> work, I'm advocating a synchronous call path from user to kernel to
> >> hardware so we can return a actionable result code, and put the burden
> >> of resource management in user-space, not in the kernel.
> >>
> > Scott you mean synchronous to the switchdev driver right ?
> 
> Correct.

So while I agree with you that it would be ideal to be synchronous all
the way to the hardware (and that is what I continue to tell vendors
they should do) you would like to see each driver individually manage
whether or not they chose to make these calls async and handle the
fallout in their own?

I'm fine with that for now since Dave's opinion on most of this is that
we need to "keep it simple" for now (he said that once already today),
but I think it is something we should consider for the future.
