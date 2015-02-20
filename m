From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: TX offloads for NVGRE (OVS GRE with inner protocol being TEB)
Date: Fri, 20 Feb 2015 09:54:21 +0200
Message-ID: <CAJ3xEMggVJ6Lm7vmFhW2PSPv612WQ4-sNWPpefkMcy1RQv+7=g@mail.gmail.com>
References: <54E5ED9D.8080206@mellanox.com>
	<CAEP_g=_SSKYEhmQ2MXJN0wP8POiwjg49txExdrorUkzw8oCRmg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	Joe Stringer <joestringer@nicira.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f173.google.com ([209.85.214.173]:43033 "EHLO
	mail-ob0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751805AbbBTHyW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2015 02:54:22 -0500
Received: by mail-ob0-f173.google.com with SMTP id uy5so22759881obc.4
        for <netdev@vger.kernel.org>; Thu, 19 Feb 2015 23:54:21 -0800 (PST)
In-Reply-To: <CAEP_g=_SSKYEhmQ2MXJN0wP8POiwjg49txExdrorUkzw8oCRmg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 19, 2015 at 7:01 PM, Jesse Gross <jesse@nicira.com> wrote:
> On Thu, Feb 19, 2015 at 6:05 AM, Or Gerlitz <ogerlitz@mellanox.com> wrote:

>> It seems that the OVS GRE code lacks handling of offloads (e.g to come into
>> play with NICs that support NVGRE).
>>
>> I assume we need to place a call to iptunnel_handle_offloads before invoking
>> iptunnel_xmit, agree? so ~the quick patch below should do the work? I wasn't
>> sure how to set the value of the 2nd param for iptunnel_handle_offloads().
>
> I don't think that this is the issue. __build_header() calls
> gre_handle_offloads() which should do all of this work already.

yep... gre_handle_offloads() is called, so something else goes wrong here.

> I did notice that skb_set_inner_protocol() is not being called because
> it is in the wrong place in the GRE encapsulation code. It is
> currently in ip_gre.c():__gre_xmit(), if that line was moved to
> gre_demux.c:gre_build_header() then it would be used by all callers.

Oh, thanks, I'll add that and see if / how much does it help.

> One other thing that is potentially an issue for offloads is that all
> of the encapsulations call vlan_hwaccel_push_inside() after the
> respective handle_offloads code. This doesn't seem right as it could
> affect the layer pointers, although it only likely matters in a
> minority of cases where the inner MAC pointer is used.

mmm, I don't think we're failing on that now, but can look this up too.


Did you ever tested Linux OVS/NGRE with a NIC that can do offloads for
this type of traffic?
