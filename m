From: Andrew Yourtchenko <ayourtch@gmail.com>
Subject: Re: [PATCH v2 2/2] ipv6: fixup RTF_* flags when restoring RTPROT_RA
 route from rtnetlink
Date: Mon, 22 Aug 2016 13:04:27 +0200 (CEST)
Message-ID: <alpine.DEB.2.20.1608221300280.31586@ayourtch-u1604b2>
References: <1471355943-21288-1-git-send-email-ayourtch@gmail.com> <cover.1471622715.git.ayourtch@gmail.com> <55219c8da12705fefa36ee5853b899ee88f730fb.1471622715.git.ayourtch@gmail.com> <689653c8-bc05-705c-04d6-ff7570b28dd0@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:36797 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751294AbcHVLEf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2016 07:04:35 -0400
Received: by mail-wm0-f65.google.com with SMTP id i138so12866933wmf.3
        for <netdev@vger.kernel.org>; Mon, 22 Aug 2016 04:04:35 -0700 (PDT)
In-Reply-To: <689653c8-bc05-705c-04d6-ff7570b28dd0@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello, 

Thanks for the review and feedback, one small clarification below.

On Fri, 19 Aug 2016, Sergei Shtylyov wrote:

> Hello.
> 
> On 08/19/2016 07:41 PM, Andrew Yourtchenko wrote:
> 
> > Fix the flags for RA-derived routes that were saved
> > via "ip -6 route save" and and subsequently restored via
> > "ip -6 route restore", allowing the incoming router advertisements
> > to update them, rather than complain about inability to do so.
> > 
> > Upon the restore of RA-derived saved routes, set the RTF_ADDRCONF
> > to indicate that the source of the route was originally
> > a router advertisement, and set the RTF_DEFAULT or RTF_ROUTEINFO
> > flag depending on prefix length. This can be considered a
> > sister change of f0396f60d7c165018c9b203fb9b89fb224835578, in
> 
>    It's enough to specify 12 digits but you also need to specify the commit
> summary enclosed in ("").

Is just the first line of "ipv6: fix RTPROT_RA markup of RA routes 
w/nexthops" enough, or do I need to include the additional two 
paragraphs that follow ? (and can I keep the full hash rather than 
truncate down to 12 digits?)

> 
> > the other direction.
> > 
> > Signed-off-by: Andrew Yourtchenko <ayourtch@gmail.com>
> > ---
> > Changes since v1 [1]:
> >  * fixed the indentation of the basic blocks to be always a full TAB
> >    as per David Miller's review
> > 
> > [1] v1: http://marc.info/?l=linux-netdev&m=147135599322285&w=2
> > 
> >  net/ipv6/route.c | 10 ++++++++++
> >  1 file changed, 10 insertions(+)
> > 
> > diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> > index f5b987d..60d95cd 100644
> > --- a/net/ipv6/route.c
> > +++ b/net/ipv6/route.c
> > @@ -2769,6 +2769,16 @@ static int rtm_to_fib6_config(struct sk_buff *skb,
> > struct nlmsghdr *nlh,
> >  	cfg->fc_protocol = rtm->rtm_protocol;
> >  	cfg->fc_type = rtm->rtm_type;
> > 
> > +	if (rtm->rtm_protocol == RTPROT_RA) {
> > +		/* RA-derived route: set flags accordingly. */
> > +		cfg->fc_flags |= RTF_ADDRCONF;
> > +		if (rtm->rtm_dst_len == 0) {
> > +			cfg->fc_flags |= RTF_DEFAULT;
> > +		} else {
> > +			cfg->fc_flags |= RTF_ROUTEINFO;
> > +		}
> 
>    {} not needed here and above.

Will fix in v3, thanks!

--a


> 
> [...]
> 
> MBR, Sergei
> 
> 
