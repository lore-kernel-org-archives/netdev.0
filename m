From: Jesse Gross <jesse@nicira.com>
Subject: Re: [ovs-dev] [PATCH v2.39 0/7] MPLS actions and matches
Date: Fri, 13 Sep 2013 15:15:17 -0700
Message-ID: <CAEP_g=9ji2ihWrVuoUrcZswrOCz_f2SFeYBTwPzbB7p=ONCPUA@mail.gmail.com>
References: <1378711207-29890-1-git-send-email-horms@verge.net.au>
 <20130912190636.GL16044@nicira.com> <20130912225614.GB30229@verge.net.au> <20130912225439.GH25242@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Simon Horman <horms@verge.net.au>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>,
	Isaku Yamahata <yamahata@valinux.co.jp>,
	Ravi K <rkerur@gmail.com>
To: Ben Pfaff <blp@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog134.obsmtp.com ([74.125.149.83]:46702 "HELO
	na3sys009aog134.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754761Ab3IMWPi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Sep 2013 18:15:38 -0400
Received: by mail-ie0-f177.google.com with SMTP id qd12so3639790ieb.8
        for <netdev@vger.kernel.org>; Fri, 13 Sep 2013 15:15:38 -0700 (PDT)
In-Reply-To: <20130912225439.GH25242@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 12, 2013 at 3:54 PM, Ben Pfaff <blp@nicira.com> wrote:
> On Fri, Sep 13, 2013 at 07:56:14AM +0900, Simon Horman wrote:
>> On Thu, Sep 12, 2013 at 12:06:36PM -0700, Ben Pfaff wrote:
>> > I've totally lost track of the status of this patch series.  I assume it
>> > needs Jesse's review.  Jesse, if I'm wrong about that, let me know and
>> > I'll take a pass at it.
>>
>> My understanding is that you have looked over the approach
>> taken for the non-datapath code and were happy with it in
>> the context that it needed review from Jesse along with the
>> datapath code.
>>
>> I believe it was a few revisions ago that you looked over
>> the series but I don't believe the non-datapath code has changed
>> in a meaningful way since then.
>
> That sounds plausible, thanks for refreshing my memory.

I haven't really reviewed the userspace code but there is one thing in
particular that concerns me: mpls_depth in the flow structure. We
obviously can't be making flow-level decisions on information that the
kernel doesn't include in the flow and I think that it is mostly
vestigial at this point. However, at best the name seems misleading
and at worst could result in someone trying to use information that we
don't really have. Can we fix this somehow? Maybe using the BoS bit?
