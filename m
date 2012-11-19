From: Joseph Glanville <joseph.glanville@orionvm.com.au>
Subject: Re: [PATCH] vxlan: Fix error that was resulting in VXLAN MTU size
 being 10 bytes too large
Date: Mon, 19 Nov 2012 22:33:50 +1100
Message-ID: <CAOzFzEiuhqiNiiij9P+sh8_ypyXN4zABeRB6tzH2TQqVsNHjCA@mail.gmail.com>
References: <20121109233354.17208.36271.stgit@gitlad.jf.intel.com>
	<20121113.143719.1473223615602040380.davem@davemloft.net>
	<20121113133353.227ec987@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, alexander.h.duyck@intel.com,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:33080 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751429Ab2KSLdu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2012 06:33:50 -0500
Received: by mail-ie0-f174.google.com with SMTP id k13so6538562iea.19
        for <netdev@vger.kernel.org>; Mon, 19 Nov 2012 03:33:50 -0800 (PST)
In-Reply-To: <20121113133353.227ec987@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14 November 2012 08:33, Stephen Hemminger <shemminger@vyatta.com> wrote:
> On Tue, 13 Nov 2012 14:37:19 -0500 (EST)
> David Miller <davem@davemloft.net> wrote:
>
>> From: Alexander Duyck <alexander.h.duyck@intel.com>
>> Date: Fri, 09 Nov 2012 15:35:24 -0800
>>
>> > This change fixes an issue I found where VXLAN frames were fragmented when
>> > they were up to the VXLAN MTU size.  I root caused the issue to the fact that
>> > the headroom was 4 + 20 + 8 + 8.  This math doesn't appear to be correct
>> > because we are not inserting a VLAN header, but instead a 2nd Ethernet header.
>> > As such the math for the overhead should be 20 + 8 + 8 + 14 to account for the
>> > extra headers that are inserted for VXLAN.
>> >
>> > Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
>>
>> Applied, thanks for the detailed commit message.
>
> Probably need smarter code there to look at header length requirement
> of underlying device as well, maybe someone will be perverse and runn
> vxlan over a tunnel or IPoIB.

Forgive my ignorance but why would running VXLAN on IPoIB require
special header handling? (and would it work or behave strangely?)

I was planning on giving this a go when 3.7 is released but I might do
that sooner if problems are anticipated.

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Joseph.

-- 
CTO | Orion Virtualisation Solutions | www.orionvm.com.au
Phone: 1300 56 99 52 | Mobile: 0428 754 846
