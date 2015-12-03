From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v1 1/6] net: Generalize udp based tunnel offload
Date: Thu, 03 Dec 2015 17:43:41 +0100
Message-ID: <1449161021.20955.457151201.71B15FA7@webmail.messagingengine.com>
References: <1448312579-159544-1-git-send-email-anjali.singhai@intel.com>
 <1448312579-159544-2-git-send-email-anjali.singhai@intel.com>
 <CALx6S34+_AtjO94znh7vW4py5a8Nj1g6b-sjGPCa4U1Mc6Y6-w@mail.gmail.com>
 <20151129.222138.1582847465760563254.davem@davemloft.net>
 <CAEh+42ivCoBE-vAwWpHHmHYqcXzKP+ceZSvg2rEPh7Db3M1k6Q@mail.gmail.com>
 <CALx6S35_rXPsYUGcc+yrQX8K1dOcL4aWnmQsa-6X6xULo9BBbg@mail.gmail.com>
 <CAEh+42gvn=cjZ4E3nACR7=-_a4iFS7OwEsSb+SQGme2k19kVAA@mail.gmail.com>
 <CALx6S37EoLM=bZ6sSAiiF81X=SvTvoNAmkbH5Dmn9zSvR2oiUA@mail.gmail.com>
 <20151201154445.GF29497@tuxdriver.com>
 <1448984968.3382143.454794705.68D88B7D@webmail.messagingengine.com>
 <CALx6S36i7Ee3Njs6OPVndyoGz1OpYss3YRPG8KO2ehxvAe50dA@mail.gmail.com>
 <1449074114.3806253.455834737.16948E5F@webmail.messagingengine.com>
 <CALx6S34Zqn1t4RPkAoa3QT-vWLvawnBN19qEZ12P-YiCEckxHw@mail.gmail.com>
 <1449158374.11080.456996721.69F803D7@webmail.messagingengine.com>
 <56606F5E.4070209@tpip.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Jesse Gross <jesse@kernel.org>,
	David Miller <davem@davemloft.net>,
	Anjali Singhai Jain <anjali.singhai@intel.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Kiran Patil <kiran.patil@intel.com>
To: Andreas Schultz <aschultz@tpip.net>,
	Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:49018 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751592AbbLCQnm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2015 11:43:42 -0500
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 360ED20825
	for <netdev@vger.kernel.org>; Thu,  3 Dec 2015 11:43:42 -0500 (EST)
In-Reply-To: <56606F5E.4070209@tpip.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 3, 2015, at 17:35, Andreas Schultz wrote:
> On 12/03/2015 04:59 PM, Hannes Frederic Sowa wrote:
> > Hi Tom,
> >
> > On Wed, Dec 2, 2015, at 20:15, Tom Herbert wrote:
> >> On Wed, Dec 2, 2015 at 8:35 AM, Hannes Frederic Sowa
> >> <hannes@stressinduktion.org> wrote:
> >>> On Wed, Dec 2, 2015, at 04:50, Tom Herbert wrote:
> >>>> That completely misses the whole point of the rest of this thread.
> >>>> Protocol specific offloads are what we are trying to discourage not
> >>>> encourage. Adding any more ndo functions for this purpose should be an
> >>>> exception, not the norm. The bar should be naturally high considering
> >>>> the cost of exposing this to ndo.
> >>>
> >>> Why?
> >>>
> >>> I wonder why we need protocol generic offloads? I know there are
> >>> currently a lot of overlay encapsulation protocols. Are there many more
> >>> coming?
> >>>
> >> Yes, and assume that there are more coming with an unbounded limit
> >> (for instance I just noticed today that there is a netdev1.1 talk on
> >> supporting GTP in the kernel). Besides, this problem space not just
> >> limited to offload of encapsulation protocols, but how to generalize
> >> offload of any transport, IPv[46], application protocols, protocol
> >> implemented in user space, security protocols, etc.
> >
> > GTP seems to be a tunneling protocol also based on TCP, I hope the same
> > standards apply to it as STT at that time (depending on the
> > implementation, of course). There are some other protocols on its way, I
> > see but they can just be realized as kernel modules and that's it.
> 
> GTP is UDP based. The standard permits a variable length header (one can
> add extensions after a fixed header), but that is seldom (or even never)
> used. Tunnel are identified by a 32bit tunnel endpoint id for GTPv1 and
> a 64bit flow id for GTPv0. UDP destination ports differ for v1 and v0,
> so it's easy to distinguish.

Ok, thanks for letting me know. Browsing in Wikipedia first mentioned
both TCP and UDP. But I see that v1 only uses UDP.

Bye,
Hannes
