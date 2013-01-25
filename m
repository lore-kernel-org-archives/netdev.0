From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH 2/2] v2 GRE: Add segmentation offload for GRE
Date: Thu, 24 Jan 2013 19:38:16 -0800
Message-ID: <CALnjE+p0m7E7vH20M9mXuNiFG4iUpAsoyjW7ugez3ch=RdkVcw@mail.gmail.com>
References: <1359065793-1796-1-git-send-email-pshelar@nicira.com>
	<1359070199.12374.2557.camel@edumazet-glaptop>
	<CALnjE+rbqCgRwxr1TtFH92vKSJoTRhBP50f+jQmgWB9LanQhYw@mail.gmail.com>
	<1359077664.12374.2887.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, jesse@nicira.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog132.obsmtp.com ([74.125.149.250]:56067 "HELO
	na3sys009aog132.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755179Ab3AYDiR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jan 2013 22:38:17 -0500
Received: by mail-vc0-f199.google.com with SMTP id fo13so7569612vcb.10
        for <netdev@vger.kernel.org>; Thu, 24 Jan 2013 19:38:16 -0800 (PST)
In-Reply-To: <1359077664.12374.2887.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 24, 2013 at 5:34 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2013-01-24 at 16:14 -0800, Pravin Shelar wrote:
>
>> I think this patch does fix csum issue without causing any performance
>> regression. So this patch shld be enough to solve GRE-GSO issue. Once
>> you have fix, this code can be optimized even more.
>
> It adds the extra copy, since you assume no SG capability so
> skb_segment() _does_ a copy.
>
OK,I wil use device features.

> As the checksum is needed, its true the copy is almost not noticed,
> but one day NIC will be able to perform the checksum for us.
> (Maybe its already the case for some of them)
>
> I would first fix the checksum issue in a generic way, then
> apply this patch on top of the fix, so that we can use SG and avoid
> the extra copy for the typical tcp_sendmsg()

I thought you were working on the fix. If not I will post patch.
>
> It seems you focus on the TAP use case only, seeing you removed
> code that doesn't work for TAP but do work for regular locally
> terminated flows.
>
I have tested patch with GRE TAP and non TAP devices.

> You did a lot of implementation choices and none of them
> are described in a changelog, making future work a bit hard.
>

ok. I will update changelog.
