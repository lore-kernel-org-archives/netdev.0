From: Lorenzo Colitti <lorenzo-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v7 0/6] Add eBPF hooks for cgroups
Date: Sat, 29 Oct 2016 12:51:37 +0900
Message-ID: <CAKD1Yr2aRDNUxX8onReZyURufphxGoSTek=Fjk3Wswq9WOVp4w@mail.gmail.com>
References: <1477390454-12553-1-git-send-email-daniel@zonque.org>
 <20161026195933.GA2031@salvia> <c9683122-d770-355b-e275-7c446e6d1d0f@zonque.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Pablo Neira Ayuso <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>, htejun-b10kYP2dOMg@public.gmane.org,
        Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>, ast-b10kYP2dOMg@public.gmane.org,
        David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, kafai-b10kYP2dOMg@public.gmane.org,
        Florian Westphal <fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org>, harald-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Daniel Mack <daniel-cYrQPVfZoowdnm+yROfE0A@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <c9683122-d770-355b-e275-7c446e6d1d0f-cYrQPVfZoowdnm+yROfE0A@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 27, 2016 at 5:40 PM, Daniel Mack <daniel-cYrQPVfZoowdnm+yROfE0A@public.gmane.org> wrote:
> It's not anything new. These hooks live on the very same level as
> SO_ATTACH_FILTER. The only differences are that the BPF programs are
> stored in the cgroup, and not in the socket, and that they exist for
> egress as well.

What's the use case for egress?

We (android networking) are currently looking at implementing network
accounting via eBPF in order to replace the out-of-tree xt_qtaguid
code. A per-cgroup eBPF program run on all traffic would be great. But
when we looked at this patchset we realized it would not be useful for
accounting purposes because even if a packet is counted here, it might
still be dropped by netfilter hooks.

It seems like it would be much more useful to be able to do this in an
iptables rule.
