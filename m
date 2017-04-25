From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH net-next 0/2] flower: add MPLS matching support
Date: Tue, 25 Apr 2017 13:55:00 +0200
Message-ID: <20170425115459.GA23939@vergenet.net>
References: <1492894367-11637-1-git-send-email-benjamin.lahaise@netronome.com>
 <20170424.143257.1003081554810761464.davem@davemloft.net>
 <d54cca4b-6212-bf7d-93e2-8314177df42c@mojatatu.com>
 <20170424182054.116d1a99@cakuba.netronome.com>
 <6ae82894-fc8b-2ad9-7dfd-cf74cd6042a1@mojatatu.com>
 <e58fd7ee-1bd0-0cd5-ab15-c510ec4e70bd@mojatatu.com>
 <8f6e7952-b87b-8959-b45a-ab687b69fb1b@mojatatu.com>
 <20170424190743.4ad24ad1@cakuba.netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
        David Miller <davem@davemloft.net>,
        benjamin.lahaise@netronome.com, netdev@vger.kernel.org,
        bcrl@kvack.org, Jiri Pirko <jiri@resnulli.us>
To: Jakub Kicinski <kubakici@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f176.google.com ([209.85.128.176]:33273 "EHLO
        mail-wr0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1176756AbdDYLzJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 07:55:09 -0400
Received: by mail-wr0-f176.google.com with SMTP id w50so84089113wrc.0
        for <netdev@vger.kernel.org>; Tue, 25 Apr 2017 04:55:03 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170424190743.4ad24ad1@cakuba.netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 24, 2017 at 07:07:43PM -0700, Jakub Kicinski wrote:
> On Mon, 24 Apr 2017 22:06:08 -0400, Jamal Hadi Salim wrote:
> > On 17-04-24 10:00 PM, Jamal Hadi Salim wrote:
> > > On 17-04-24 09:48 PM, Jamal Hadi Salim wrote:  
> > 
> > >
> > > Hrm. maybe I am wrong.
> > > Lets say user sets all of the 8 bits in BOS,
> > > what does setting
> > > key_val->mpls_bos = nla_get_u8 do?
> > >
> > > Same with the 20 bits for the label in the u32
> > > or 3 bit bits in the u8 tc.  
> > 
> > The label and tc are masked - maybe just the BOS
> > needs something similar?
> 
> Indeed, good catch!

I agree something should be done wrt BOS. If the LABEL and TC are to
be left as-is then I think a similar treatment of BOS - that is masking it
- makes sense.

I also agree with statements made earlier in the thread that it is unlikely
that the unused bits of these attributes will be used - as opposed to a
bitmask of flag values which seems ripe for re-use for future flags.

I would like to add to the discussion that I think in future it would
be good to expand the features provided by this patch to support supplying
a mask as part of the match - as flower supports for other fields such
as IP addresses. But I think the current scheme of masking out invalid bits
should also work in conjunction with user-supplied masks.
