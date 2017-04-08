From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 1/5] netlink: extended ACK reporting
Date: Sat, 08 Apr 2017 20:37:01 +0200
Message-ID: <1491676621.5800.24.camel@sipsolutions.net>
References: <20170408174900.12820-1-johannes@sipsolutions.net>
         <20170408174900.12820-2-johannes@sipsolutions.net>
         <20170408183440.GA1900@nanopsycho> (sfid-20170408_203444_598631_EBE98730)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        pablo@netfilter.org, Jamal Hadi Salim <jhs@mojatatu.com>,
        Jiri Benc <jbenc@redhat.com>,
        David Ahern <dsa@cumulusnetworks.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:38860 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752612AbdDHShG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 8 Apr 2017 14:37:06 -0400
In-Reply-To: <20170408183440.GA1900@nanopsycho> (sfid-20170408_203444_598631_EBE98730)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2017-04-08 at 20:34 +0200, Jiri Pirko wrote:
> nla_total_size(sizeof(u32));
> > +			if (extack &&
> > +			    (extack->missing_attr || extack-
> > >bad_attr))
> 
> Attr could be 0, right? I know that on the most of the places 0 is
> UNSPEC, but I'm pretty sure not everywhere.

Yeah, I guess we can't show a missing attribute of 0 now - bad_attr is
a pointer so no problem there.

I think I'll leave it like this - if anyone really wants to say
"attribute 0 is missing" then we can add a flag later... The UAPI does
take this into account by not including the attribute at all if the
data is invalid, so 0 in the userspace API can be done

johannes
