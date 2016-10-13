From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH net 2/2] conntrack: enable to tune gc parameters
Date: Thu, 13 Oct 2016 22:43:38 +0200
Message-ID: <20161013204338.GA32449@breakpoint.cc>
References: <1476094704-17452-1-git-send-email-nicolas.dichtel@6wind.com>
 <1476094704-17452-3-git-send-email-nicolas.dichtel@6wind.com>
 <20161010140424.GB21057@breakpoint.cc>
 <cdda5290-c49c-e841-6ba5-10b30fd04fc0@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: 8bit
Cc: Florian Westphal <fw@strlen.de>, davem@davemloft.net,
        pablo@netfilter.org, netdev@vger.kernel.org,
        netfilter-devel@vger.kernel.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <cdda5290-c49c-e841-6ba5-10b30fd04fc0@6wind.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Nicolas Dichtel <nicolas.dichtel@6wind.com> wrote:
> Le 10/10/2016 à 16:04, Florian Westphal a écrit :
> > Nicolas Dichtel <nicolas.dichtel@6wind.com> wrote:
> >> After commit b87a2f9199ea ("netfilter: conntrack: add gc worker to remove
> >> timed-out entries"), netlink conntrack deletion events may be sent with a
> >> huge delay. It could be interesting to let the user tweak gc parameters
> >> depending on its use case.
> > 
> > Hmm, care to elaborate?
> > 
> > I am not against doing this but I'd like to hear/read your use case.
> > 
> > The expectation is that in almot all cases eviction will happen from
> > packet path.  The gc worker is jusdt there for case where a busy system
> > goes idle.
> It was precisely that case. After a period of activity, the event is sent a long
> time after the timeout. If the router does not manage a lot of flows, why not
> trying to parse more entries instead of the default 1/64 of the table?
> In fact, I don't understand why using GC_MAX_BUCKETS_DIV instead of using always
> GC_MAX_BUCKETS whatever the size of the table is.

I wanted to make sure that we have a known upper bound on the number of
buckets we process so that we do not block other pending kworker items
for too long.

(Or cause too many useless scans)

Another idea worth trying might be to get rid of the max cap and
instead break early in case too many jiffies expired.

I don't want to add sysctl knobs for this unless absolutely needed; its already
possible to 'force' eviction cycle by running 'conntrack -L'.
