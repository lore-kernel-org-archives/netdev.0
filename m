From: Tony Jeffree <tony@jeffree.co.uk>
Subject: Re: 802.1D/Linux STP issue
Date: Thu, 14 Sep 2006 17:51:50 +0100
Message-ID: <6.0.1.1.2.20060914174624.05055480@mail.expressoweb.co.uk>
References: <OF1AE42FF9.06C5D926-ON852571E7.005804CC-852571E7.0057EE7E@ieee.org>
 <45076B88.80104@bristyle.com>
 <6.0.1.1.2.20060913075410.04133280@mail.expressoweb.co.uk>
 <45088D29.30501@bristyle.com>
 <20060914100619.76cb1828@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; format=flowed
Cc: Brian Braunstein <brian@bristyle.com>,
	Rajesh Mishra <rajesh_mish@yahoo.com>, bridge@osdl.org,
	netdev@vger.kernel.org, mick_seaman@ieee.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from he303war.uk.vianw.net ([195.102.244.166]:3712 "EHLO
	he303war.uk.vianw.net") by vger.kernel.org with ESMTP
	id S1750728AbWINQv7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Sep 2006 12:51:59 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060914100619.76cb1828@localhost.localdomain>
References: <OF1AE42FF9.06C5D926-ON852571E7.005804CC-852571E7.0057EE7E@ieee.org>
 <45076B88.80104@bristyle.com>
 <6.0.1.1.2.20060913075410.04133280@mail.expressoweb.co.uk>
 <45088D29.30501@bristyle.com>
 <20060914100619.76cb1828@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Steve/Brian -

You've probably seen Mick Seaman's comments on this by now - as he points 
out in his email, tinkering with existing STP implementations is not likely 
to be a rewarding exercise and I would encourage you not to go there.

I would suggest that it would be a much more valuable exercise for the 
Linux community to replace the existing STP support with an implementation 
of RSTP.

Regards,
Tony

At 02:06 14/09/2006, Stephen Hemminger wrote:
>On Wed, 13 Sep 2006 15:58:49 -0700
>Brian Braunstein <brian@bristyle.com> wrote:
>
> > hi stephen and tony,
> >
> > i have been in contact with both of you and i figured it would make
> > sense to get you to in contact on this issue, so here's the story:
> >
> > stephen is the maintainer of the linux spanning tree bridging code, an
> > implementation of 802.1D-1998 that has very wide spread use.
> >
> > tony is the chair of the IEEE802.1 working group.
> >
> > i am trying to get my patch submitted in the linux kernel to fix a bug
> > in the way STP behaves.  stephen and i discovered that the flaw is
> > actually in the IEEE802.1D-1998 spec, and that the linux implementation
> > was merely following this.  i contacted tony to try to see if we can get
> > an update to the 802.1D-1998 spec, as this is what is implemented in the
> > linux kernel, but tony said that the 1998 standard is obsolete, will not
> > be updated,  and that the 2004 RSTP spec should be used.
> >
> > so here's a review of what i've come across:
> >
> > first lets start with the bug in the 802.1D-1998 spec
> >
> > 1998 - 8.6.2.2 Record Configuration Information - Use
> >     you will notice that if the path cost ever goes up and everything
> > else is held constant, the BPDU will be dropped and the network not
> > react to the change, and the dropping of the BPDUs will make it seem
> > like the link is down.
> >
> > now lets look at the equivalent section in the 8021.D-2004 spec:
> >
> > 2004 - 17.6 Priority vector calculations
> >
> >     as you can see here, this bug has been fixed, because the last
> > condition takes care of the problem, if the config message is received
> > from the same designated bridge and designated port, then the config
> > message is processed. so path cost increases will be recorded and
> > reacted to.
> >
> >
> > the issue is whether or not the linux kernel should go with the 1998 or
> > 2004 spec.  i would assume that the goal is to make the linux
> > implmentation a functional implementation of the original STP, not a
> > complete rewrite to conform to all of RSTP, so lets look at what the new
> > standard says for normal legacy STP, to see if the bug is fixed there as
> > well:
> >
> > 2004 - 17.4 STP compatibility
> >
> >     this section seems to say that an RSTP bridge  will revert to STP as
> > defined in section 8.  so then we go to section 8...
> >
> > 2004 - 8 Spanning tree algorithm protocol
> >
> >     this one then refers to 802.1D-1998 for the STP spec, but also says
> > that it is obsolete and RSTP should be used
> >
> > so this is a bit confusing.  section 17.4 says use STP to interoperate
> > with legacy bridges, then section 8 either says use the 1998 spec, or
> > don't use STP at all, but if bugs in the 1998 spec cannot be correct,
> > what are we to do with the linux code?  i can write the patch to
> > implement the new algorithm from 2004-17.6 to replace the algorithm from
> > 1998-8.6.2.2.
> >
> > thanks for you help guys,
> > hopefully we can get this bug fixed up soon, you both have been great
> > about timely responses and it is much appreciated.
> >
> > Brian Braunstein
> > 858.245.0434
>
>
>I have no problem fixing the code to be spec noncompliant, there
>are several case where we implement the "right thing" rather than
>the "standard way". I just want to make sure any such changes don't
>have unintended consequences.



