From: Daniel Mack <daniel-cYrQPVfZoowdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH v6 5/6] net: ipv4, ipv6: run cgroup eBPF egress programs
Date: Mon, 19 Sep 2016 22:56:14 +0200
Message-ID: <83afdc54-1bbe-3530-e5fd-b74fefe9a042@zonque.org>
References: <1474303441-3745-1-git-send-email-daniel@zonque.org>
 <1474303441-3745-6-git-send-email-daniel@zonque.org>
 <20160919191910.GA984@salvia>
 <ac88bb4c-ab7c-1f74-c7fd-79e523b50ae4@zonque.org>
 <20160919203533.GA888@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: htejun-b10kYP2dOMg@public.gmane.org, daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org, ast-b10kYP2dOMg@public.gmane.org,
        davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, kafai-b10kYP2dOMg@public.gmane.org, fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org, harald-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Pablo Neira Ayuso <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160919203533.GA888@salvia>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 09/19/2016 10:35 PM, Pablo Neira Ayuso wrote:
> On Mon, Sep 19, 2016 at 09:30:02PM +0200, Daniel Mack wrote:
>> On 09/19/2016 09:19 PM, Pablo Neira Ayuso wrote:

>>> Actually, did you look at Google's approach to this problem?  They
>>> want to control this at socket level, so you restrict what the process
>>> can actually bind. That is enforcing the policy way before you even
>>> send packets. On top of that, what they submitted is infrastructured
>>> so any process with CAP_NET_ADMIN can access that policy that is being
>>> applied and fetch a readable policy through kernel interface.
>>
>> Yes, I've seen what they propose, but I want this approach to support
>> accounting, and so the code has to look at each and every packet in
>> order to count bytes and packets. Do you know of any better place to put
>> the hook then?
> 
> Accounting is part of the usecase that fits into the "network
> introspection" idea that has been mentioned here, so you can achieve
> this by adding a hook that returns no verdict, so this becomes similar
> to the tracing infrastructure.

Why would we artificially limit the use-cases of this implementation if
the way it stands, both filtering and introspection are possible?

> Filtering packets with cgroups is braindead.

Filtering is done via eBPF, and cgroups are just the containers. I don't
see what's brain-dead in that approach. After all, accessing the cgroup
once we have a local socket is really fast, so the idea is kinda obvious.

> You have the means to ensure that processes send no packets via
> restricting port binding, there is no reason to do this any later for
> locally generated traffic.

Yes, restricting port binding can be done on top, if people are worried
about the performance overhead of a per-packet program.



Thanks,
Daniel
