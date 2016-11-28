From: =?gb2312?B?1cXKpL7Z?= <zhangshengju@cmss.chinamobile.com>
Subject: RE: [net,v2] neigh: fix the loop index error in neigh dump
Date: Mon, 28 Nov 2016 12:50:39 +0800
Message-ID: <001e01d24932$f7c0dd10$e7429730$@cmss.chinamobile.com>
References: <1480296725-5563-1-git-send-email-zhangshengju@cmss.chinamobile.com> <caa11887-00b9-d2f1-7c0b-5b5096b42f56@cumulusnetworks.com> <001c01d2491f$fcd53250$f67f96f0$@cmss.chinamobile.com> <6d1a324e-e29e-e2dd-a6fc-1e9b4455cb3d@cumulusnetworks.com> <001d01d24922$9a16b1e0$ce4415a0$@cmss.chinamobile.com> <a01fcd54-c0ed-9d05-743a-27592d845c56@cumulusnetworks.com> <6859d40b-0049-513a-6dc4-162d383ef7b9@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain;
        charset="gb2312"
Content-Transfer-Encoding: 8BIT
To: "'David Ahern'" <dsa@cumulusnetworks.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta3.chinamobile.com ([221.176.66.81]:18331 "EHLO
        cmccmta3.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753327AbcK1Evi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 27 Nov 2016 23:51:38 -0500
In-Reply-To: <6859d40b-0049-513a-6dc4-162d383ef7b9@cumulusnetworks.com>
Content-Language: en-us
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: David Ahern [mailto:dsa@cumulusnetworks.com]
> Sent: Monday, November 28, 2016 11:10 AM
> To: 张胜举 <zhangshengju@cmss.chinamobile.com>;
> netdev@vger.kernel.org
> Subject: Re: [net,v2] neigh: fix the loop index error in neigh dump
> 
> On 11/27/16 7:56 PM, David Ahern wrote:
> > On 11/27/16 7:53 PM, 张胜举 wrote:
> >>
> >>
> >>> -----Original Message-----
> >>> From: David Ahern [mailto:dsa@cumulusnetworks.com]
> >>> Sent: Monday, November 28, 2016 10:39 AM
> >>> To: 张胜举 <zhangshengju@cmss.chinamobile.com>;
> >>> netdev@vger.kernel.org
> >>> Subject: Re: [net,v2] neigh: fix the loop index error in neigh dump
> >>>
> >>> On 11/27/16 7:34 PM, 张胜举 wrote:
> >>>>> -----Original Message-----
> >>>>> From: David Ahern [mailto:dsa@cumulusnetworks.com]
> >>>>> Sent: Monday, November 28, 2016 10:10 AM
> >>>>> To: Zhang Shengju <zhangshengju@cmss.chinamobile.com>;
> >>>>> netdev@vger.kernel.org
> >>>>> Subject: Re: [net,v2] neigh: fix the loop index error in neigh
> >>>>> dump
> >>>>>
> >>>>> On 11/27/16 6:32 PM, Zhang Shengju wrote:
> >>>>>> Loop index in neigh dump function is not updated correctly under
> >>>>>> some circumstances, this patch will fix it.
> >>>>>
> >>>>> What's an example?
> >>>>
> >>>> If dev is filtered out, the original code goes to next loop without
> >>>> updating loop index 'idx'.
> >>>
> >>> And you have a use case with missing or redundant data? Or is your
> >>> comment based on a review of code only?
> >> It's on my code review. No use case currently,  this is uncommon to
> happen.
> >>
> >>
> >>>
> >>>>> You are completely rewriting the dump loops.
> >>>>
> >>>> I put 'idx++' into for loop,  so I replace 'goto' with 'continue'.
> >>>> The other change is style related.
> >>>
> >>> A "fixes" should not include 'style related' changes.
> >> Okay, I will send another version without style changes.
> >>
> >
> > Personally, I think you need to produce a use case that fails before
sending
> another patch. I have not seen a problem with this code.
> >
> 
> And looking back at 3f0ae05d6f I should not have acked it (reviewed it too
> quickly while on PTO). Your change is a no-op because of what idx
represents
> - the position in the hash list for devices relevant for the dump request.
> Same goes for the neigh dump so this patch is not needed.
> 
No, when dump request must be processed by multiple 'recv/recvmsg' system
calls, 
idx stores which dev/neigh the previous call have processed, so that next
call will scan 
from the right place.  

So no matter whether the dev/neigh is filtered, the idx should be increased
anyway.

It's hard to produce a use case, because we mostly have only one entity in
hash list. Even with
multiple entities, we also need the function to exit right at the place
where dev/neigh is filter out.

All other dump functiones for RT netlink keep this logic, you can refer
inet_dump_ifaddr() if you wish.
