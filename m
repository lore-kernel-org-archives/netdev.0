From: Venkat Yekkirala <vyekkirala@TrustedCS.com>
Subject: RE: [PATCH 7/7] secid reconciliation-v03: Enforcement for SELinux
Date: Fri, 29 Sep 2006 18:10:05 -0400
Message-ID: <36282A1733C57546BE392885C0618592015CF3BE@chaos.tcs.tcs-sec.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: Stephen Smalley <sds@tycho.nsa.gov>,
	Joshua Brindle <method@gentoo.org>, netdev@vger.kernel.org,
	selinux@tycho.nsa.gov, kmacmillan@mentalrootkit.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:54306 "EHLO
	tcsfw4.tcs-sec.com") by vger.kernel.org with ESMTP id S1750711AbWI2WKb
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Sep 2006 18:10:31 -0400
To: Paul Moore <paul.moore@hp.com>, James Morris <jmorris@namei.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> >>>>It seems more of a pain to actually
> >>>>prevent their use at the same time and/or explain 
> strange/unnatural
> >>>>behavior.
> >>>
> >>>Agreed, the solution that we agreed upon is much easier to 
> implement and
> >>>explain than a lot of the alternatives.
> >>
> >>Ok, can you please explain it further?
> >>
> >>i.e. show me what the policy looks like, exactly what the 
> user is trying 
> >>to achieve, and explain what happens to each packet exactly 
> in terms of 
> >>labeling on the input and output paths.
> >  
> > Also, why can't this be done just with xfrm labeling?
> 
> I believe the issue Venkat and I were discussing was how to handle the
> case of multiple external labeling protocols, i.e. what to do 
> if we get
> a packet through labeled SA which has a CIPSO option.  As I've said
> before, I don't believe this is something we will see much in practice
> but I think we need to decide what to do: handle it somehow 
> or just punt
> on the problem and drop it.  Several people with experience with
> external labeling have commented on how supporting both external
> labeling protocols would be a good idea so Venkat and I are trying to
> come up with a solution that works.

Here's the scoop on using xfrm and cipso at the same time:

JUST REDUNDANT

I was only paying attention to the inbound side when I was
saying a ranged SA could be used in conjunction with fine-grained
cipso labeling. In actuality, this isn't possible because of the
change we are instituting for SA selection to be based on the context
of the sock (specifically, the sock's MLS range must "equal" the range
on the SA, and cipso at this point would be representing this same range).

So, if someone were to configure CIPSO along with labeled ipsec, BOTH
mechanisms will be used, with BOTH labels carrying the same MLS range,
and with CIPSO always overriding the SA (after a
flow_in check) on the inbound. Should just be additional overhead, that's
all.
