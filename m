From: Ani Sinha <ani@arista.com>
Subject: Re: route/max_size sysctl in ipv4
Date: Fri, 9 Jan 2015 11:08:25 -0800
Message-ID: <CAOxq_8Na14ES1souk-jBa8A=9ArHc-ffRtSd36zbvwHvGM+24Q@mail.gmail.com>
References: <CAOxq_8NdxBScZ182bXs5KmTZLKRMeF3AVt+DJNFUff42gaZG4w@mail.gmail.com>
 <20150105.193614.1827024424476781168.davem@davemloft.net> <CAOxq_8OtQ0WD-PKBd4kX0JwZiaStqJ-cQiQRhWnTAK9Q0JquxA@mail.gmail.com>
 <20150105.195128.794605376092864881.davem@davemloft.net> <CAOxq_8MoPocarmhdXQOkc=4HfGh1L+5-ozEdwPzn2K8q4Gh55w@mail.gmail.com>
 <CAOxq_8PeZFGGsHoT7Ef0gJezV=UikMQqM0UvQZQcpOywxBOy4w@mail.gmail.com>
 <1420683594.5947.43.camel@edumazet-glaptop2.roam.corp.google.com>
 <CAOxq_8Pp7fwsV3Y+-LNheziQzP8FXqT3ohgMt7SeEs6+nuGxMg@mail.gmail.com>
 <1420695665.5947.44.camel@edumazet-glaptop2.roam.corp.google.com>
 <CAOxq_8OPj4twFg2U93hFNSjeiZ5We5DgeCo-W5hSbXJvQmZfyQ@mail.gmail.com>
 <1420743808.5947.73.camel@edumazet-glaptop2.roam.corp.google.com>
 <CAOxq_8M=Ros56U_VbUVumjS226jHs1DK0A-K9aRksTMu88H_sg@mail.gmail.com> <CAHA+R7Ps2_+5NgjE8HNbrTxbjhtt4nJyK9y5HrbHez2PhZEiPQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f180.google.com ([209.85.223.180]:43692 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750773AbbAITIq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2015 14:08:46 -0500
Received: by mail-ie0-f180.google.com with SMTP id rp18so16635397iec.11
        for <netdev@vger.kernel.org>; Fri, 09 Jan 2015 11:08:46 -0800 (PST)
In-Reply-To: <CAHA+R7Ps2_+5NgjE8HNbrTxbjhtt4nJyK9y5HrbHez2PhZEiPQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 9, 2015 at 10:47 AM, Cong Wang <cwang@twopensource.com> wrote:
> On Thu, Jan 8, 2015 at 12:13 PM, Ani Sinha <ani@arista.com> wrote:
>> On Thu, Jan 8, 2015 at 11:03 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>>>
>>> If you want to use network namespaces, you have to adapt your scripts.
>>>
>>> Nobody claimed network namespaces were totally transparent.
>>>
>>
>> I see. I am going back to an old thread here where Linus says that the
>> #1 rule is:
>>
>> ""We don't regress user space"
>>
>> https://lkml.org/lkml/2013/7/16/565
>>
>> Breaking scripts seems to me to fall into the category of regressing
>> userspace. Or may be we can treat these sysctls more softly since they
>> are not strictly speaking linux ABIs.
>
> As Eric said, it has been like this since day 0,

I beg to differ. It has not been like this for that particular sysctl
from day 0. That sysctl was available from a child namespace and now
it isn't.

why you still think
> we break something? It is you who misunderstands the interface
> not us who break your script.

Perhaps. What I am truly confused about is :

- We are keeping a sysctl interface that does absolutely nothing in
the kernel and is completely useless in case some userland
scripts/tools are rendered broken from it's removal.

- surprisingly, we contradict ourselves when we let scripts break when
running from a child namespace because the  same sysctl is no longer
available!

When the source is available for a script or tool, it's easy to change
the code to conform to the new semantics. However, for old binaries
for which we do not have any source, it's not easy or is impossible to
fix them.

I rest my case. We will of course find a way to fix our code if that
is what netdev thinks is the way to go.
