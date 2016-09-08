From: Phil Sutter <phil@nwl.cc>
Subject: Re: [PATCH bug-fix] iproute: fix documentation for ip rule scan order
Date: Thu, 8 Sep 2016 12:33:03 +0200
Message-ID: <20160908103303.GG5252@orbyte.nwl.cc>
References: <CAN04xNR8SH4D57mfY0nVDSNWvZfaaOLci2yB0-8nKg=Hv9SEbw@mail.gmail.com>
 <20160901090454.657f0b73@xeon-e3>
 <20160908095955.GA10034@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        Iskren Chernev <iskren@imo.im>, netdev@vger.kernel.org
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:59546 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S938941AbcIHKdH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 8 Sep 2016 06:33:07 -0400
Content-Disposition: inline
In-Reply-To: <20160908095955.GA10034@unicorn.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Thu, Sep 08, 2016 at 11:59:55AM +0200, Michal Kubecek wrote:
> On Thu, Sep 01, 2016 at 09:04:54AM -0700, Stephen Hemminger wrote:
> > On Tue, 30 Aug 2016 17:32:52 -0700
> > Iskren Chernev <iskren@imo.im> wrote:
> > 
> > > From 416f45b62f33017d19a9b14e7b0179807c993cbe Mon Sep 17 00:00:00 2001
> > > From: Iskren Chernev <iskren@imo.im>
> > > Date: Tue, 30 Aug 2016 17:08:54 -0700
> > > Subject: [PATCH bug-fix] iproute: fix documentation for ip rule scan order
> > > 
> > > ---
> > >  man/man8/ip-rule.8 | 2 +-
> > >  1 file changed, 1 insertion(+), 1 deletion(-)
> > > 
> > > diff --git a/man/man8/ip-rule.8 b/man/man8/ip-rule.8
> > > index 1774ae3..3508d80 100644
> > > --- a/man/man8/ip-rule.8
> > > +++ b/man/man8/ip-rule.8
> > > @@ -93,7 +93,7 @@ Each policy routing rule consists of a
> > >  .B selector
> > >  and an
> > >  .B action predicate.
> > > -The RPDB is scanned in order of decreasing priority. The selector
> > > +The RPDB is scanned in order of increasing priority. The selector
> > >  of each rule is applied to {source address, destination address,
> > > incoming
> > >  interface, tos, fwmark} and, if the selector matches the packet,
> > >  the action is performed. The action predicate may return with success.
> > > --
> > > 2.4.5
> > 
> > Applied
> 
> I'm sorry I didn't notice before but this just reverts the change done
> by commit 49572501664d ("iproute2: clarification of various man8 pages").
> IMHO the problem is that both versions are equally confusing as the word
> "priority" can be understood in two different senses.
> 
> How about more explicit formulation, e.g.
> 
>   ... in order of decreasing logical priority (i.e. increasing numeric
>   values).
> 
> Would that be better?

Looks like the real issue is missing definition of priority. What about
this:

diff --git a/man/man8/ip-rule.8 b/man/man8/ip-rule.8
index 3508d8090fd2c..13fe9f7f892ee 100644
--- a/man/man8/ip-rule.8
+++ b/man/man8/ip-rule.8
@@ -93,7 +93,7 @@ Each policy routing rule consists of a
 .B selector
 and an
 .B action predicate.
-The RPDB is scanned in order of increasing priority. The selector
+The RPDB is scanned in order of decreasing priority. The selector
 of each rule is applied to {source address, destination address, incoming
 interface, tos, fwmark} and, if the selector matches the packet,
 the action is performed. The action predicate may return with success.
@@ -221,8 +221,10 @@ value to match.
 
 .TP
 .BI priority " PREFERENCE"
-the priority of this rule. Each rule should have an explicitly
-set
+the priority of this rule.
+.I PREFERENCE
+is an unsigned integer value, higher number means lower priority.  Each rule
+should have an explicitly set
 .I unique
 priority value.
 The options preference and order are synonyms with priority.
