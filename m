From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH nf V2] netfilter: fix oops in nfqueue during netns error unwinding
Date: Fri, 13 May 2016 19:58:28 -0500
Message-ID: <87k2ixo3pn.fsf@x220.int.ebiederm.org>
References: <1462981273-21676-1-git-send-email-fw@strlen.de>
	<20160512094725.GB1777@salvia> <87twi3qmlf.fsf@x220.int.ebiederm.org>
	<20160512164000.GA9815@breakpoint.cc>
	<87a8jtrbk3.fsf@x220.int.ebiederm.org>
	<20160513200442.GA29941@breakpoint.cc>
	<87zirtofgp.fsf@x220.int.ebiederm.org>
	<20160513212029.GC29941@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org, dale.4d@gmail.com,
	netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20160513212029.GC29941@breakpoint.cc> (Florian Westphal's
	message of "Fri, 13 May 2016 23:20:29 +0200")
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Florian Westphal <fw@strlen.de> writes:

> Eric W. Biederman <ebiederm@xmission.com> wrote:
>> Florian could you test and verify this patch fixes your issues?
>
> Yes, this seems to work.
>
> Pablo, I'm fine with this patch going into -nf/stable but I do not think
> making the pointers per netns is a desireable option in the long term.
>
>> Unlike the other possibilities that have been discussed this also
>> addresses the nf_queue path as well as the nf_queue_hook_drop path.
>
> The nf_queue path should have been fine, no?
>
> Or putting it differently: can we start processing skbs before a netns
> is fully initialized?

The practical case that worries me is what happens when someone does
"rmmod nfnetlink_queue" while the system is running.  It appears to me
that today we could free the per netns data during the rcu grace period
and cause a similar issue in nfnl_queue_pernet.

That looks like it could affect both the nf_queue path and the
nf_queue_nf_hook_drop path.

Eric



