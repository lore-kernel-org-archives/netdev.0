From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net-next] net: make neigh tables per netns
Date: Fri, 27 Jun 2014 17:09:15 -0700
Message-ID: <CAM_iQpX7iPR=32kog=QJm4G1tgRfg80Hr8Y=BOgUiGnym5EmKw@mail.gmail.com>
References: <87lhskpizv.fsf@x220.int.ebiederm.org>
	<20140626.134335.2147671135749217539.davem@davemloft.net>
	<87egybibh5.fsf@x220.int.ebiederm.org>
	<20140626.154428.1099304313432511688.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Cong Wang <cwang@twopensource.com>,
	Stefan Bader <stefan.bader@canonical.com>,
	stephane.graber@canonical.com, chris.j.arges@canonical.com,
	Serge Hallyn <serge.hallyn@canonical.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f54.google.com ([209.85.219.54]:63551 "EHLO
	mail-oa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754839AbaF1AJQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2014 20:09:16 -0400
Received: by mail-oa0-f54.google.com with SMTP id eb12so6487973oac.27
        for <netdev@vger.kernel.org>; Fri, 27 Jun 2014 17:09:15 -0700 (PDT)
In-Reply-To: <20140626.154428.1099304313432511688.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 26, 2014 at 3:44 PM, David Miller <davem@davemloft.net> wrote:
>
> First of all it is clear that once you start creating containers on the
> order of half the global neigh limit, yes you will run into problems as
> it's easy to have 2 or more outputs in flight.
>
> So it would perhaps be wise to scale the limits (in some way) based
> upon the number of namespaces, but still keep it a global limit.
>
> These entries consume a global resource (memory) and benefit from
> global sharing, so I am still convinced that making the tables
> themselves per-ns does not make any sense.
>
> Secondly, if there are things holding onto neighbour entries for real
> we should find this out.  Once could audit neigh_lookup*() invocations
> to see where that might be happening.  Also neigh_create() calls with
> 'want_ref' set to true.
>

Hmm, I did overlook the potential DOS problem. But hold on, isn't
IP fragments have the same problem? The fragment queues are per
netns, and the thresh is per netns as well, we will eventually have
memory pressure as well.

I will dig this deeper to see if there is any better solution.

Thanks.
