From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 1/3] Security: Add prctl(PR_{GET,SET}_NETWORK)
Date: Fri, 18 Dec 2009 09:47:23 -0800
Message-ID: <m13a38uqc4.fsf@fess.ebiederm.org>
References: <20091218154634.79decdc4@lxorguk.ukuu.org.uk>
	<20091218163348.GA24269@heat>
	<20091218172054.556de51b@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, Alan Cox <alan@lxorguk.ukuu.org.uk>,
	netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	Andi Kleen <andi@firstfloor.org>, David Lang <david@lang.hm>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Valdis Kletnieks <Valdis.Kletnieks@vt.edu>,
	Bryan Donlan <bdonlan@gmail.com>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	"C. Scott Ananian" <cscott@cscott.net>,
	James Morris <jmorris@namei.org>,
	Bernie Innocenti <bernie@codewiz.org>,
	Mark Seaborn <mrs@mythic-beasts.com>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	=?utf-8?Q?Am=C3=A9rico?= Wang <xiyou.wangcong@gmail.com>
To: Michael Stone <michael@laptop.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:52309 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932294AbZLRRrj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Dec 2009 12:47:39 -0500
In-Reply-To: <20091218172054.556de51b@lxorguk.ukuu.org.uk> (Alan Cox's message of "Fri\, 18 Dec 2009 17\:20\:54 +0000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alan Cox <alan@lxorguk.ukuu.org.uk> writes:

>> the LSM-based version *does not* resolve the situation to my satisfaction as a
>> userland hacker due to the well-known and long-standing adoption and
>> compositionality problems facing small LSMs. ;)
>
> For things like Fedora it's probably an "interesting idea, perhaps we
> should do it using SELinux" sort of problem, but a config option for a
> magic network prctl is also going to be hard to adopt without producing a
> good use case - and avoiding that by dumping crap into everyones kernel
> fast paths isn't a good idea either.

If I understand the problem the goal is to disable access to ipc
mechanism that don't have the usual unix permissions.  To get
something that is usable for non-root processes, and to get something
that is widely deployed so you don't have to jump through hoops in
end user applications to use it.

We have widely deployed mechanisms that are what you want or nearly
what you want already in the form of the various namespaces built for
containers.

I propose you introduce a permanent disable of executing suid 
applications. 

After which point it is another trivial patch to allow unsharing of
the network namespace if executing suid applications are disabled.

Eric
