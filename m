From: David Ahern <dsa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>
Subject: Re: [PATCH v6 0/6] Add eBPF hooks for cgroups
Date: Thu, 20 Oct 2016 23:32:11 -0600
Message-ID: <455cf1d0-15c0-09f7-1460-d91be269d33c@cumulusnetworks.com>
References: <1474303441-3745-1-git-send-email-daniel@zonque.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, kafai-b10kYP2dOMg@public.gmane.org, fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org,
        pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org, harald-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Daniel Mack <daniel-cYrQPVfZoowdnm+yROfE0A@public.gmane.org>, htejun-b10kYP2dOMg@public.gmane.org,
        daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org, ast-b10kYP2dOMg@public.gmane.org,
        Pablo Neira Ayuso <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1474303441-3745-1-git-send-email-daniel-cYrQPVfZoowdnm+yROfE0A@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 9/19/16 10:43 AM, Daniel Mack wrote:
> This is v6 of the patch set to allow eBPF programs for network
> filtering and accounting to be attached to cgroups, so that they apply
> to all sockets of all tasks placed in that cgroup. The logic also
> allows to be extendeded for other cgroup based eBPF logic.
> 
> 
> Changes from v5:
> 
> * The eBPF programs now operate on L3 rather than on L2 of the packets,
>   and the egress hooks were moved from __dev_queue_xmit() to
>   ip*_output().
> 
> * For BPF_PROG_TYPE_CGROUP_SOCKET, disallow direct access to the skb
>   through BPF_LD_[ABS|IND] instructions, but hook up the
>   bpf_skb_load_bytes() access helper instead. Thanks to Daniel Borkmann
>   for the help.

It's been a month since the last response or update to this series. Any progress in resolving the resistance to hook locations?

As I mentioned in Tokyo I need a solution for VRF that allows running processes in a VRF context -- meaning a process inherits a default sk_bound_dev_if for any AF_INET{6} sockets opened. Right now we (Cumulus) are using an l3mdev cgroup, something that Tejun pushed back on earlier this year. I strongly believe that cgroups provide the right infrastructure for this feature and looking at options. I'm sure a few people will chuckle about this, but I do have another solution that leverages this patchset -- a bpf program on a cgroup that sets sk_bound_dev_if. So, what's the likelihood of this patchset making 4.10 (or any other release)?

Thanks,
David
