From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH bug-fix] iproute: fix documentation for ip rule scan
 order
Date: Tue, 20 Sep 2016 09:38:15 -0700
Message-ID: <20160920093815.2408f8b3@xeon-e3>
References: <CAN04xNR8SH4D57mfY0nVDSNWvZfaaOLci2yB0-8nKg=Hv9SEbw@mail.gmail.com>
 <20160901090454.657f0b73@xeon-e3>
 <20160908095955.GA10034@unicorn.suse.cz>
 <20160908103303.GG5252@orbyte.nwl.cc>
 <20160908114808.GB10034@unicorn.suse.cz>
 <20160908124317.GK5252@orbyte.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Michal Kubecek <mkubecek@suse.cz>, Iskren Chernev <iskren@imo.im>,
        netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:33726 "EHLO
        mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754132AbcITQiG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 12:38:06 -0400
Received: by mail-pa0-f47.google.com with SMTP id hm5so8702769pac.0
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2016 09:38:05 -0700 (PDT)
In-Reply-To: <20160908124317.GK5252@orbyte.nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 8 Sep 2016 14:43:17 +0200
Phil Sutter <phil@nwl.cc> wrote:

> On Thu, Sep 08, 2016 at 01:48:08PM +0200, Michal Kubecek wrote:
> > On Thu, Sep 08, 2016 at 12:33:03PM +0200, Phil Sutter wrote:  
> > > On Thu, Sep 08, 2016 at 11:59:55AM +0200, Michal Kubecek wrote:  
> > > > 
> > > > I'm sorry I didn't notice before but this just reverts the change done
> > > > by commit 49572501664d ("iproute2: clarification of various man8 pages").
> > > > IMHO the problem is that both versions are equally confusing as the word
> > > > "priority" can be understood in two different senses.
> > > > 
> > > > How about more explicit formulation, e.g.
> > > > 
> > > >   ... in order of decreasing logical priority (i.e. increasing numeric
> > > >   values).
> > > > 
> > > > Would that be better?  
> > > 
> > > Looks like the real issue is missing definition of priority. What about
> > > this:
> > > 
> > > diff --git a/man/man8/ip-rule.8 b/man/man8/ip-rule.8
> > > index 3508d8090fd2c..13fe9f7f892ee 100644
> > > --- a/man/man8/ip-rule.8
> > > +++ b/man/man8/ip-rule.8
> > > @@ -93,7 +93,7 @@ Each policy routing rule consists of a
> > >  .B selector
> > >  and an
> > >  .B action predicate.
> > > -The RPDB is scanned in order of increasing priority. The selector
> > > +The RPDB is scanned in order of decreasing priority. The selector
> > >  of each rule is applied to {source address, destination address, incoming
> > >  interface, tos, fwmark} and, if the selector matches the packet,
> > >  the action is performed. The action predicate may return with success.
> > > @@ -221,8 +221,10 @@ value to match.
> > >  
> > >  .TP
> > >  .BI priority " PREFERENCE"
> > > -the priority of this rule. Each rule should have an explicitly
> > > -set
> > > +the priority of this rule.
> > > +.I PREFERENCE
> > > +is an unsigned integer value, higher number means lower priority.  Each rule
> > > +should have an explicitly set
> > >  .I unique
> > >  priority value.
> > >  The options preference and order are synonyms with priority.  
> > 
> > Formally, this would be certainly sufficient. But for clarity (and
> > inattentive readers), I would still prefer to be more explicit in the
> > first hunk, e.g.
> > 
> >   ... in order of decreasing priority (increasing PREFERENCE values).  
> 
> I'm fine with that, though fear mentioning PREFERENCE here might confuse
> readers. I'd go with "i.e. increasing numeric values" instead. But after
> all this is quite a discussion for such a tiny bit of documentation. :)
> 
> Cheers, Phil

I put in the documentation change, if you want to modify send another patch.
