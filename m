From: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Subject: Re: Need a creative way to negate u32 filter matches
Date: Fri, 29 May 2015 23:36:34 -0400
Message-ID: <1432956994.4289.6.camel@jasiiieee.pacifera.com>
References: <1432953129.4289.5.camel@jasiiieee.pacifera.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.perfora.net ([74.208.4.197]:64331 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757299AbbE3Dgi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 May 2015 23:36:38 -0400
Received: from [192.168.1.3] ([69.116.52.45]) by mrelay.perfora.net
 (mreueus002) with ESMTPSA (Nemesis) id 0LmdAz-1ZY9dm1P8t-00aFza for
 <netdev@vger.kernel.org>; Sat, 30 May 2015 05:36:37 +0200
In-Reply-To: <1432953129.4289.5.camel@jasiiieee.pacifera.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-05-29 at 22:32 -0400, John A. Sullivan III wrote:
> Hello, all.  I understand there is no direct way to negate a u32 match.
> I have a setup where I am redirecting all ingress traffic from the
> physical interface to an ifb interface with a u32 match u8 0 0 action
> mirred egress redirect filter attached to ffff:
> 
> I do not want to send ingress ESP packets to the IFB interface.  How do
> I exclude those?
> I tried creating a filter with a lower prio and added before the above
> rule which matches ESP packets and does nothing with them (action pass)
> in the hope that it would be the first match and ESP packets would then
> not be matched against the second filter.  That does not appear to be
> working from tc -s filter.  The rule is hit, the match succeeds, but the
> success count is 0 and I see the filter on the IFB interface which
> identifies ESP packets is successfully being hit.
> 
> How do I redirect all packets EXCEPT ESP packets to an IFB interface?
> Thanks - John

I just stumbled across ematch.  This seems to do the trick by allowing
negation - John
