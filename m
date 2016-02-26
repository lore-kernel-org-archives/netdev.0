From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next 5/5] vxlan: implement GPE in L3 mode
Date: Fri, 26 Feb 2016 15:42:29 -0800
Message-ID: <CALx6S357WXaHBs0Tnf=PCcBZGr2Ryv8jr6rms_TWtYDytmRSKw@mail.gmail.com>
References: <cover.1456472746.git.jbenc@redhat.com>
	<20f9916704dc3b34526bc0959e7212de7ec878a4.1456472746.git.jbenc@redhat.com>
	<CAEh+42hC=Bx3FFGH=Eij-HGNN5jgZh_PmBbzp_3YPnWKpyTn1w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jiri Benc <jbenc@redhat.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Jesse Gross <jesse@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:33946 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755249AbcBZXma (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2016 18:42:30 -0500
Received: by mail-ig0-f180.google.com with SMTP id g6so49460157igt.1
        for <netdev@vger.kernel.org>; Fri, 26 Feb 2016 15:42:30 -0800 (PST)
In-Reply-To: <CAEh+42hC=Bx3FFGH=Eij-HGNN5jgZh_PmBbzp_3YPnWKpyTn1w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 26, 2016 at 2:22 PM, Jesse Gross <jesse@kernel.org> wrote:
> On Thu, Feb 25, 2016 at 11:48 PM, Jiri Benc <jbenc@redhat.com> wrote:
>> diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
>> index c2b2b7462731..ee4f7198aa21 100644
>> --- a/include/uapi/linux/if_link.h
>> +++ b/include/uapi/linux/if_link.h
>> @@ -464,6 +464,7 @@ enum {
>>  enum vxlan_gpe_mode {
>>         VXLAN_GPE_MODE_DISABLED = 0,
>>         VXLAN_GPE_MODE_L2,
>> +       VXLAN_GPE_MODE_L3,
>
> Given that VXLAN_GPE_MODE_L3 will eventually come to be used by NSH,
> MPLS, etc. in addition to IPv4/v6, most of which are not really L3, it
> seems like something along the lines of NO_ARP might be better since
> that's what it really indicates. Once that is in, I don't really see
> the need to explicitly block Ethernet packets from being handled in
> this mode. If they are received, then they can just be handed off to
> the stack - at that point it would look like an extra header, the same
> as if an NSH packet is received.

Agreed, and I don't see why there even needs to be modes. VXLAN-GPE
can carry arbitrary protocols with a next-header field. For Ethernet,
MPLS, IPv4, and IPv6 it should just be a simple mapping of the next
header to Ethertype for purposes of processing the payload.
