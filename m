From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH v2 net-next] rtnetlink: bridge: use ext_ack instead of
 printk
Date: Tue, 10 Oct 2017 16:28:11 +0200
Message-ID: <20171010142811.GA2132@breakpoint.cc>
References: <20171010113236.8889-1-fw@strlen.de>
 <9c01905a-92e1-1246-35ee-2a60ac11733e@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:34106 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932075AbdJJO2Q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Oct 2017 10:28:16 -0400
Content-Disposition: inline
In-Reply-To: <9c01905a-92e1-1246-35ee-2a60ac11733e@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Ahern <dsahern@gmail.com> wrote:
> On 10/10/17 5:32 AM, Florian Westphal wrote:
> > diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> > index e84d108cfee4..19ea53a5210f 100644
> > --- a/net/core/rtnetlink.c
> > +++ b/net/core/rtnetlink.c
> > @@ -3066,21 +3066,22 @@ int ndo_dflt_fdb_add(struct ndmsg *ndm,
> >  }
> >  EXPORT_SYMBOL(ndo_dflt_fdb_add);
> >  
> > -static int fdb_vid_parse(struct nlattr *vlan_attr, u16 *p_vid)
> > +static int fdb_vid_parse(struct nlattr *vlan_attr, u16 *p_vid,
> > +			 struct netlink_ext_ack *exta)
> >  {
> >  	u16 vid = 0;
> >  
> >  	if (vlan_attr) {
> >  		if (nla_len(vlan_attr) != sizeof(u16)) {
> > -			pr_info("PF_BRIDGE: RTM_NEWNEIGH with invalid vlan\n");
> > +			NL_SET_ERR_MSG(exta, "RTM_NEWNEIGH with invalid vlan");
> 
> I realize you are keeping the existing wording, but the messages are
> moving from out of line pr_info to inline message in response to a user
> command.  From a user's perspective the RTM_NEWNEIGH and DELNEIGH do not
> add much value, and the add and del in the bridge command tells which it
> is. So in this case just emit "Invalid vlan id".

Right, makes sense.

> Although this failure is an invalid vlan attribute as opposed to an
> invalid vlan id which is what the next message checks. So the message
> needs to be updated as well.

Indeed, I'll send a v2, thanks!
