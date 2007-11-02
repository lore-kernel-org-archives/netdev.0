From: jamal <hadi@cyberus.ca>
Subject: Re: Endianness problem with u32 classifier hash masks
Date: Fri, 02 Nov 2007 19:23:50 -0400
Message-ID: <1194045830.4438.21.camel@localhost>
References: <1193939701.2987.82.camel@localhost.localdomain>
	 <472B5EF1.4020206@o2.pl>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Radu Rendec <radu.rendec@ines.ro>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.181]:11963 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755747AbXKCAkX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Nov 2007 20:40:23 -0400
Received: by wa-out-1112.google.com with SMTP id v27so1121651wah
        for <netdev@vger.kernel.org>; Fri, 02 Nov 2007 17:40:22 -0700 (PDT)
In-Reply-To: <472B5EF1.4020206@o2.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Fri, 2007-02-11 at 18:31 +0100, Jarek Poplawski wrote:
> Radu Rendec wrote:
> 
> > Hi,
> > 
> > While trying to implement u32 hashes in my shaping machine I ran into a
> > possible bug in the u32 hash/bucket computing algorithm
> > (net/sched/cls_u32.c).
> > 
> > The problem occurs only with hash masks that extend over the octet
> > boundary, on little endian machines (where htonl() actually does
> > something).
> > 
> > I'm not 100% sure this is a problem with u32 itself, but at least I'm
> > sure u32 with the same configuration would behave differently on little
> > endian and big endian machines. Detailed description of the problem and
> > proposed patch follow.
> 
> 
> I think you are right about this different behavior, so it looks like a bug.
> And since little endian way is uncontrollable in such a case, your proposal
> should be right.
> 
> But, since there is a maintainer for this, let's check what is he not payed
> for?! (Cc: Jamal Hadi Salim)
> 

Thanks for the CC Jarek - and i promise to share the loot with you when
i lay my hands on it;->

I see that given the mask described (the 0 bits bounding the two
nibbles), the same packet in that network will hit two different buckets
depending on endianness. In other words there is lack of consistency. So
good catch.
The patch would certainly resolve it.
The only thing that bothers me with the patch approach is the extra
conversion in the fast path. Radu, since this is not a show stopper -
can you give me a short time to sip on it? I am thinking it is probably
resolvable by using the right tuning at config time - one knob that
looks usable is fshift and that all this can be done at config time; but
i may need more than one coffee to get it right, but if you see it just
send a patch. I will try to use the data you used to see if i am making
any sense.

cheers,
jamal

