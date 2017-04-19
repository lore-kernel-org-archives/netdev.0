From: Matthias Kaehlcke <mka@chromium.org>
Subject: Re: [PATCH] netfilter: ctnetlink: Make some parameters integer to
 avoid enum mismatch
Date: Wed, 19 Apr 2017 12:59:14 -0700
Message-ID: <20170419195914.GG128305@google.com>
References: <20170419183920.21936-1-mka@chromium.org>
 <1492630870.30293.3.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        "David S . Miller" <davem@davemloft.net>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Grant Grundler <grundler@chromium.org>,
        Greg Hackmann <ghackmann@google.com>,
        Michael Davidson <md@google.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f182.google.com ([209.85.223.182]:35984 "EHLO
        mail-io0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S936149AbdDST7Q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Apr 2017 15:59:16 -0400
Received: by mail-io0-f182.google.com with SMTP id o22so37242561iod.3
        for <netdev@vger.kernel.org>; Wed, 19 Apr 2017 12:59:16 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1492630870.30293.3.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

El Wed, Apr 19, 2017 at 12:41:10PM -0700 Joe Perches ha dit:

> On Wed, 2017-04-19 at 11:39 -0700, Matthias Kaehlcke wrote:
> > Not all parameters passed to ctnetlink_parse_tuple() and
> > ctnetlink_exp_dump_tuple() match the enum type in the signatures of these
> > functions.
> 
> Maybe that should be changed/fixed.

Please see the previous discussion at
http://www.spinics.net/lists/netfilter-devel/msg47540.html

> > Since this is intended change the argument type of to be an int
> > value.
> 
> u32 is not int, it's unsigned int

I would argue that an unsigned int is an int(eger) and considered it
an unnecessary detail for the commit message to be explicit. I can
change it if others deem it incorrect.

Cheers

Matthias

> > Signed-off-by: Matthias Kaehlcke <mka@chromium.org>
> > ---
> >  net/netfilter/nf_conntrack_netlink.c | 7 +++----
> >  1 file changed, 3 insertions(+), 4 deletions(-)
> > 
> > diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
> > index dc7dfd68fafe..775eb5d9165b 100644
> > --- a/net/netfilter/nf_conntrack_netlink.c
> > +++ b/net/netfilter/nf_conntrack_netlink.c
> > @@ -1006,9 +1006,8 @@ static const struct nla_policy tuple_nla_policy[CTA_TUPLE_MAX+1] = {
> >  
> >  static int
> >  ctnetlink_parse_tuple(const struct nlattr * const cda[],
> > -		      struct nf_conntrack_tuple *tuple,
> > -		      enum ctattr_type type, u_int8_t l3num,
> > -		      struct nf_conntrack_zone *zone)
> > +		      struct nf_conntrack_tuple *tuple, u32 type,
> > +		      u_int8_t l3num, struct nf_conntrack_zone *zone)
> >  {
> >  	struct nlattr *tb[CTA_TUPLE_MAX+1];
> >  	int err;
> > @@ -2443,7 +2442,7 @@ static struct nfnl_ct_hook ctnetlink_glue_hook = {
> >  
> >  static int ctnetlink_exp_dump_tuple(struct sk_buff *skb,
> >  				    const struct nf_conntrack_tuple *tuple,
> > -				    enum ctattr_expect type)
> > +				    u32 type)
> >  {
> >  	struct nlattr *nest_parms;
> >  
