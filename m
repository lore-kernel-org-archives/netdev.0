From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH/RFC net-next 0/4] net/sched: cls_flower: avoid false
 matching of truncated packets
Date: Sun, 30 Apr 2017 09:51:30 -0400
Message-ID: <0e993860-4dfd-3562-5ccb-c5ad24e5f970@mojatatu.com>
References: <20170428120035.15984-1-simon.horman@netronome.com>
 <422d55da-f861-1bc6-983d-199fc383c113@mojatatu.com>
 <20170428131155.GA30329@vergenet.net>
 <2c14754a-f3f5-cece-2cd7-361948a00c22@mojatatu.com>
 <20170428141414.GA11256@vergenet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@mellanox.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Dinan Gunawardena <dinan.gunawardena@netronome.com>,
        netdev@vger.kernel.org, oss-drivers@netronome.com
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f49.google.com ([209.85.214.49]:35480 "EHLO
        mail-it0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S968372AbdD3Nve (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Apr 2017 09:51:34 -0400
Received: by mail-it0-f49.google.com with SMTP id c15so3142685ith.0
        for <netdev@vger.kernel.org>; Sun, 30 Apr 2017 06:51:33 -0700 (PDT)
In-Reply-To: <20170428141414.GA11256@vergenet.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-04-28 10:14 AM, Simon Horman wrote:
> On Fri, Apr 28, 2017 at 09:41:00AM -0400, Jamal Hadi Salim wrote:
>> On 17-04-28 09:11 AM, Simon Horman wrote:
[..]
>> A default lower prio match all on udp or icmp?
>
> I'm certainly not opposed to exploring ideas here.
>
> The way that flower currently works is that a match on ip_proto ==
> UDP/TCP/SCTP/ICMP but not fields in the L4 header itself would not result in
> the dissector only dissecting the packet's L4 header and thus would not
> discover (or as in currently the case, silently ignore) the absence of the
> ports/ICMP type and code in the L4 header.
>
> What my patch attempts to do is to describe a policy of what to do if
> a given classifier invokes the dissector (to pull out the headers needed for
> the match in question) and that dissection fails. Its basically describing
> the error-path.
>

Understood - I was struggling with whether error-path is the same as
"didnt match".

>
> There are two issues:
>
> 1. As things stand, without this patch-set, flower does not differentiate
>    between a packet truncated at the end of the IP header and a packet with
>    zero ports. Likewise for icmp type and code of zero.
>
>    The first three patches of this series address that so that a match for
>    port == zero only matches if ports are present in the packet. Again,
>    likewise for ICMP.
>
>    This is a bug-fix to my way of thinking.
>

Agreed to bug fix. I would have said there is never a legit packet with
TCP/UDP but I think some fingerprinting apps use it. And one would need
to distinguish between the two at classification time.
ICMP type 0 is certainly used.

minimal some flag should qualify it as "truncated".

> 2. The behaviour described above, prior to this patchset, might have been
>    utilised to f.e. drop packets that are either truncated or have port == 0
>    (because flower didn't differentiate between these cases).
>
>    So the question becomes if/how to provide such a feature.
>    The last patch is my attempt to answer that question.

It almost feels like you need metadata matching as well - one being
"truncated".

cheers,
jamal
