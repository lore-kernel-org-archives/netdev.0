From: Krister Johansen <kjlx@templeofstupid.com>
Subject: Re: [PATCH iproute/master 2/3] iptunnel: add support for mpls/ip to
 sit tunnels
Date: Wed, 14 Jun 2017 10:11:19 -0700
Message-ID: <20170614171119.GB2368@templeofstupid.com>
References: <1497058292-10099-1-git-send-email-kjlx@templeofstupid.com>
 <1497058292-10099-3-git-send-email-kjlx@templeofstupid.com>
 <20170614100211.1346dc4e@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Krister Johansen <kjlx@templeofstupid.com>, netdev@vger.kernel.org,
        simon.horman@netronome.com, dsahern@gmail.com
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sub5.mail.dreamhost.com ([208.113.200.129]:35520 "EHLO
        homiemail-a68.g.dreamhost.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750735AbdFNRLR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Jun 2017 13:11:17 -0400
Received: from homiemail-a68.g.dreamhost.com (localhost [127.0.0.1])
        by homiemail-a68.g.dreamhost.com (Postfix) with ESMTP id 1F73348000B30
        for <netdev@vger.kernel.org>; Wed, 14 Jun 2017 10:11:17 -0700 (PDT)
Received: from kmjvbox (c-174-62-91-145.hsd1.ca.comcast.net [174.62.91.145])
        (using TLSv1 with cipher ECDHE-RSA-AES256-SHA (256/256 bits))
        (No client certificate requested)
        (Authenticated sender: kjlx@templeofstupid.com)
        by homiemail-a68.g.dreamhost.com (Postfix) with ESMTPSA id E02C248000B36
        for <netdev@vger.kernel.org>; Wed, 14 Jun 2017 10:11:16 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170614100211.1346dc4e@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 14, 2017 at 10:02:11AM -0700, Stephen Hemminger wrote:
> On Fri,  9 Jun 2017 18:31:31 -0700
> Krister Johansen <kjlx@templeofstupid.com> wrote:
> 
> > diff --git a/include/utils.h b/include/utils.h
> > index bfbc9e6..60ffde4 100644
> > --- a/include/utils.h
> > +++ b/include/utils.h
> > @@ -87,6 +87,9 @@ struct ipx_addr {
> >  #ifndef AF_MPLS
> >  # define AF_MPLS 28
> >  #endif
> > +#ifndef IPPROTO_MPLS
> > +#define IPPROTO_MPLS	137
> > +#endif
> >  
> 
> I am a little concerned that this definition may end up being different
> between kernel and iproute2.  It looks like utils.h already has lots of duplicate
> definitions of things that are in standard include directory.
> 
> Most of these like IPSEC and DECNET are old, but MPLS might get changed
> in the process of going into glibc.
> 
> Is there anyway to get this from the kernel headers which are cloned
> into include/linux/ already?

I did try to fix this up as part of bringing this patch up to date,
since it was one of the concerns that David raised too.  I believe the
problem that I ran into was that IPPROTO_MPLS wasn't defined in all
versions of the headers where I tried to include them, and by bringing
in in.h, I also managed to get a bunch of errors around re-definition of
other symbols.

That said, I don't believe that 137 as the IPPROTO_MPLS value should
change anytime soon.  It's defined in RFC 4023.

	https://tools.ietf.org/html/rfc4023

However, if this is still seems problematic, I can take another shot at
attempting to clean this up further.

-K
