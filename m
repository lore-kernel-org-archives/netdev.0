From: Ani Sinha <ani@aristanetworks.com>
Subject: Re: [tcpdump-workers] vlan tagged packets and libpcap breakage
Date: Thu, 13 Dec 2012 09:34:04 -0800
Message-ID: <CAOxq_8PuMF2n80g30aXbPFQyo6UfsypZOHREjB36dnnp87nv=A@mail.gmail.com>
References: <CAOxq_8Nd8VP3MaNBfUt9v82nmGDpxZz5_5QMdsruET1tjwuQPw@mail.gmail.com>
	<3246.1351717319@obiwan.sandelman.ca>
	<CAOxq_8PsXb-oUy85Eji7GSAbUZD_Bds8skmGNP4BWSewQWx8PA@mail.gmail.com>
	<21992.1351723328@obiwan.sandelman.ca>
	<alpine.OSX.2.00.1212121205040.78903@animac.local>
	<50C9936B.2000201@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Michael Richardson <mcr@sandelman.ca>, netdev@vger.kernel.org,
	tcpdump-workers@lists.tcpdump.org,
	Francesco Ruggeri <fruggeri@aristanetworks.com>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f170.google.com ([209.85.223.170]:53462 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755502Ab2LMReF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2012 12:34:05 -0500
Received: by mail-ie0-f170.google.com with SMTP id k10so4921700iea.1
        for <netdev@vger.kernel.org>; Thu, 13 Dec 2012 09:34:04 -0800 (PST)
In-Reply-To: <50C9936B.2000201@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 13, 2012 at 12:35 AM, Daniel Borkmann <dborkman@redhat.com> wrote:
> On 12/12/2012 10:53 PM, Ani Sinha wrote:
>>>
>>> unsigned int netdev_8021q_inskb = 1;
>>>
>>> ...
>>>         {
>>>                 .ctl_name       = NET_CORE_8021q_INSKB,
>>>                 .procname       = "netdev_8021q_inskb",
>>>                 .data           = &netdev_8021q_inskb,
>>>                 .maxlen         = sizeof(int),
>>>                 .mode           = 0444,
>>>                 .proc_handler   = proc_dointvec
>>>         },
>>>
>>> would seem to do it to me.
>>> Then pcap can fopen("/proc/sys/net/core/netdev_8021q_inskb") and if it
>>> finds it, and it is >0, then do the cmsg thing.
>>>
>>
>
> I think it doesn't. Because then you are obviously considering adding one
> procfs file into /proc/sys/net/core/ *for each* feature that is added into
> the ancillary ops which cannot be the right way ...

We had already brought up this topic previously in the same thread. A
suggestion was made to add that proc entry and no one from netdev
responded to it saying that it did not make any sense. Therefore
before I went ahead and made the fixes in libpcap, I wanted to run
this by your guys again to make sure we are still on the same page.

I do agree that instead of a /proc entry, we should check for a kenrel
version >= X where X is the upstream version that first started
supporting all the features needed by libpcap for vlan filtering. This
is not a compile time check but a run time one. Does anyone see any
issues with this? Is there any long term implications of this, like if
you backport patches to an older long term supported kernel? Are there
other better ways to do this, like may be returning feature bits from
an ioctl call? This is something we need to deal with on a continuous
basis as we keep supporting newer AUX fields and libpcap and other
user land code needs to make use of it. At the same time, they need to
handle backward compatibility issues with older kernels.

Thanks
