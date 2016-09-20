From: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
Subject: Re: [PATCH v6 5/6] net: ipv4, ipv6: run cgroup eBPF egress programs
Date: Tue, 20 Sep 2016 18:53:29 +0200
Message-ID: <20160920165329.GB3291@pox.localdomain>
References: <1474303441-3745-1-git-send-email-daniel@zonque.org>
 <1474303441-3745-6-git-send-email-daniel@zonque.org>
 <20160919191910.GA984@salvia>
 <ac88bb4c-ab7c-1f74-c7fd-79e523b50ae4@zonque.org>
 <20160919203533.GA888@salvia>
 <83afdc54-1bbe-3530-e5fd-b74fefe9a042@zonque.org>
 <20160920142931.GA31438@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Mack <daniel-cYrQPVfZoowdnm+yROfE0A@public.gmane.org>, htejun-b10kYP2dOMg@public.gmane.org,
        daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org, ast-b10kYP2dOMg@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
        kafai-b10kYP2dOMg@public.gmane.org, fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org, harald-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Pablo Neira Ayuso <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20160920142931.GA31438@salvia>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 09/20/16 at 04:29pm, Pablo Neira Ayuso wrote:
> On Mon, Sep 19, 2016 at 10:56:14PM +0200, Daniel Mack wrote:
> [...]
> > Why would we artificially limit the use-cases of this implementation if
> > the way it stands, both filtering and introspection are possible?
> 
> Why should we place infrastructure in the kernel to filter packets so
> late, and why at postrouting btw, when we can do this way earlier
> before any packet is actually sent? No performance impact, no need for
> skbuff allocation and *no cycles wasted to evaluate if every packet is
> wanted or not*.

I won't argue against filtering at socket level, it is very valuable.
A difference is transparency of enforcement. Dropping at networking
level is accounted for in the usual counters and well understood by
admins. "Dropping" at bind socket level would either involve returning
an error to the application (which may change behaviour of the application)
or require a new form of accounting.

I also want to see packet size, selected source address, outgoing device,
and attach tunnel key metadata to the skb based on the cgroup. All of
which are not available at socket level.
