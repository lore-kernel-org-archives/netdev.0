From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH 1/4] Add packet recirculation
Date: Wed, 10 Apr 2013 09:21:23 -0700
Message-ID: <CAEP_g=8vE9Ykdnro+Puw34ORRnPEMn1LMBxv+f7w_Dp-uty_iw@mail.gmail.com>
References: <1365403431-18102-1-git-send-email-horms@verge.net.au>
 <1365403431-18102-2-git-send-email-horms@verge.net.au> <CAEP_g=9nj24hZcA-czzuz3xaweATxRxmibuFaqODTSoPmRmHsw@mail.gmail.com>
 <20130409075024.GG11444@verge.net.au> <CAEP_g=-baZGttBowXKGdgKafxp9fkUrQ=44y562ZzfnOL-XaQg@mail.gmail.com>
 <20130410091657.GA27777@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>, Ravi K <rkerur@gmail.com>,
	Isaku Yamahata <yamahata@valinux.co.jp>,
	Ben Pfaff <blp@nicira.com>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog126.obsmtp.com ([74.125.149.155]:44479 "HELO
	na3sys009aog126.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S936388Ab3DJQVp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Apr 2013 12:21:45 -0400
Received: by mail-ie0-f198.google.com with SMTP id 17so3488244iea.5
        for <netdev@vger.kernel.org>; Wed, 10 Apr 2013 09:21:44 -0700 (PDT)
In-Reply-To: <20130410091657.GA27777@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 10, 2013 at 2:16 AM, Simon Horman <horms@verge.net.au> wrote:
> On Tue, Apr 09, 2013 at 08:44:02AM -0700, Jesse Gross wrote:
>> On Tue, Apr 9, 2013 at 12:50 AM, Simon Horman <horms@verge.net.au> wrote:
>> > On Mon, Apr 08, 2013 at 06:46:29PM -0700, Jesse Gross wrote:
>> >> On Sun, Apr 7, 2013 at 11:43 PM, Simon Horman <horms@verge.net.au> wrote:
>> >> > diff --git a/ofproto/ofproto-dpif.c b/ofproto/ofproto-dpif.c
>> >> > index 47830c1..5129da1 100644
>> >> > --- a/ofproto/ofproto-dpif.c
>> >> > +++ b/ofproto/ofproto-dpif.c
>> >>
>> >> I'm still working on more detailed comments for this.  However, I'm
>> >> concerned about whether the behavior for revalidation and stats is
>> >> correct.
>> >
>> > I am a little concerned about that too.
>> > Perhaps Ben could look over it?
>>
>> To rephrase, there are problems in both of those areas. Validation in
>> particular I don't think handles resubmitted facets and I believe that
>> stats on rules will be the sum of all resubmitted passes.
>
> Some questions:
> By resubmitted do you mean recirculated?

Yes.

> What is the stats behaviour that you would like?

A given rule should have byte and packet counts equal to the number of
times it is matched (i.e. the first time) even if we have to decompose
it into multiple passes internally.

> With regards to validation, I assume the area of concern
> is around facet_revalidate(). I will look into that.

Yes.

>> Both of these will likely significantly affect the data structures, so
>> please look into this before we go further.
>
> Sure. I was not planning to push (much) further until this series
> is reviewed properly.

I'm planning on waiting on further reviews of this file until you've
had a chance to look into validation and stats since I think that may
change some of the data structures.
