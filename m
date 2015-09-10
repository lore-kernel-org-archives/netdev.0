From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH 2/2 v2] net: Remove VRF change to udp_sendmsg
Date: Wed, 9 Sep 2015 19:10:04 -0600
Message-ID: <55F0D86C.90903@cumulusnetworks.com>
References: <1441835862-41403-1-git-send-email-dsa@cumulusnetworks.com>
 <1441835862-41403-2-git-send-email-dsa@cumulusnetworks.com>
 <CALx6S35scg=6vr9zPBD=_VPHGDwkq22hQM4Ce2roi4j5DXrYZw@mail.gmail.com>
 <55F0CD92.7080700@cumulusnetworks.com>
 <CALx6S35Fwu5QsR-W=0LVzvZv_PGqbV3TGR9T5YRU65QCY0OgzQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:35596 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752441AbbIJBKG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2015 21:10:06 -0400
Received: by pacfv12 with SMTP id fv12so26191820pac.2
        for <netdev@vger.kernel.org>; Wed, 09 Sep 2015 18:10:06 -0700 (PDT)
In-Reply-To: <CALx6S35Fwu5QsR-W=0LVzvZv_PGqbV3TGR9T5YRU65QCY0OgzQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/9/15 6:51 PM, Tom Herbert wrote:
> It is NAT since you are changing the source address and modifying the
> transport protocol checksum below IP and transport layer. There are a
> bunch of side effects that you would need to consider. This is
> creating custom APIs changing the semantics of address selection, and
> also creates inconsistency between how addresses may be selected
> between a connected and unconnected sockets. Consider that
> ip_local_out_sk calls netfilter NF_INET_LOCAL_OUT hook before
> dst->output, so then netfilter would start seeing packets with zero
> source address???

understood.

>
> A lot of design in the stack is predicated on inet_select_addr
> returning the source address to use for sending a packet. This should
> always return a reasonable address as an invariant, if someone wishes
> to rewrite addresses at a lower layer that's fine, but that should be
> defined as a NAT operation. If a device wants to weigh in on address
> selection then we can define an ndo function for that as I mentioned
> before.

I am floating an idea internally that re-implements how VRF impacts the 
stack. It's 4.4 material and essentially adds dev_xxxx() / ndo functions 
for the intrusions. With net-next closed no since throwing them out yet 
and Nikolay always has good comments on my wild ass ideas.

David
