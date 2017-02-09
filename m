From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [oss-drivers] Re: [PATCH/RFC net-next 1/2] flow dissector: ND
 support
Date: Thu, 9 Feb 2017 09:25:39 +0100
Message-ID: <20170209082538.GA474@penelope.horms.nl>
References: <20170207.123831.1038511845714033360.davem@davemloft.net>
 <20170208092823.GA17615@penelope.horms.nl>
 <CALx6S36VrtQM5G2XPzpcrP=y3RyBwTnYJcaKqXtwyFgpGiz+Jg@mail.gmail.com>
 <20170208.135415.601520734521006340.davem@davemloft.net>
 <20170208200917.GA20719@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, tom@herbertland.com,
        eric.dumazet@gmail.com, dinan.gunawardena@netronome.com,
        netdev@vger.kernel.org, oss-drivers@netronome.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:34429 "EHLO
        mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751807AbdBIIfs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 03:35:48 -0500
Received: by mail-wm0-f53.google.com with SMTP id 196so56112598wmm.1
        for <netdev@vger.kernel.org>; Thu, 09 Feb 2017 00:34:06 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20170208200917.GA20719@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 08, 2017 at 09:09:17PM +0100, Jiri Pirko wrote:
> Wed, Feb 08, 2017 at 07:54:15PM CET, davem@davemloft.net wrote:
> >From: Tom Herbert <tom@herbertland.com>
> >Date: Wed, 8 Feb 2017 10:33:46 -0800
> >
> >> On Wed, Feb 8, 2017 at 1:28 AM, Simon Horman <simon.horman@netronome.com> wrote:
> >>> I think the above paragraph gets back to Tom's original question regarding
> >>> making things more complex just for OvS (use-cases). Possibly ND is an edge
> >>> case even for OvS and on reflection my timing for posting it seems to have
> >>> been less than ideal.
> >> 
> >> If it wasn't ND it would be something else... with all the activity
> >> happening in networking features and HW this is a timely discussion.
> >> Flow dissector presents a good example of a function that might become
> >> a dumping ground for an endless stream of features if we don't figure
> >> out how exercise some restraint.
> >
> >I agree on most points.
> >
> >But, I would say that in this specific case, since we have ARP support in
> >there already it behooves us to support the ipv6 side in the form of ND
> >too.
> >
> >Then we can put a line in the sand and say that future feature additions
> >in this area require serious discussion.

I think this serious discussion is all about the long term and am
completely in favour of that. But in the short term it would help me to
know if the line in the sand excludes proposing enhancements to protocols
already supported by the flow dissector; in particular MPLS and IP fields I
listed earlier in this thread.

Perhaps the answer is that it depends. But if the line in
the sand has been fortified I'd rather avoid trying to cross it.

> Yeah, well, and if there is a functinality that is unacceptable for any
> reason to put into flow_dissector, we have to do a flow_dissector2?
> 
> Note that I originally had separate dissection in cls_flower, you
> suggested to use the existing flow_dissector. And I still believe it was
> the right way to do it.
> 
> I think that better is to make existing flow dissector more modular.
> I'll look into this.

Making the flow dissector more modular makes some sense to me.
It seems that it should be a way to address sharing common code while
allowing more flexibility for users, such as flower, that need it.

Elsewhere in this thread there has been some discussion of BPF. While I
also think that makes sense I think that for in-kernel users it makes
more sense to allow leveraging of the flow dissector using C code.

Such an approach well allow some of the complexity that was recently added
to the flow dissector to move into more peripheral code. Which may or may
not be a win as I think was discussed earlier in this thread.
