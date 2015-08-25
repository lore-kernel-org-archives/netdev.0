From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] netlink: netlink_ack send a capped message in case of
 error
Date: Mon, 24 Aug 2015 21:19:21 -0700 (PDT)
Message-ID: <20150824.211921.944778094161045642.davem@davemloft.net>
References: <CAE4R7bAYUhbUoGK_M=USJW8pgWmBrKsNuzLFmY70aBzti53Vxg@mail.gmail.com>
	<CALD+uuz7NHdWU0qqogu6_cs81Ng6gpcCPFUr4WUF+hpQPMaysg@mail.gmail.com>
	<20150824185637.GA19923@salvia>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: christophe.ricard@gmail.com, sfeldma@gmail.com, jbenc@redhat.com,
	sameo@linux.intel.com, netdev@vger.kernel.org,
	christophe-h.ricard@st.com
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54399 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750726AbbHYETZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 00:19:25 -0400
In-Reply-To: <20150824185637.GA19923@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Mon, 24 Aug 2015 20:56:37 +0200

> On Mon, Aug 24, 2015 at 10:08:22AM +0200, Christophe Ricard wrote:
>> Hi Scott,
>> 
>> I think i understand the potential limitation of my solution.
>> I saw something was proposed by Jiri Benc who pushed an additional flag to
>> tell if the payload can be ignored in case of an error.
>> http://patchwork.ozlabs.org/patch/290976/
>> 
>> Do you think this one is acceptable ? I am not sure to understand David
>> last comment.
> 
> I think David suggests something like the (completely untested)
> attached patch.

Yes, echo'ing the entire message back in an ACK is really pointless.

Especially since if the user really is interested in noticing ACKs
it can very easily keep the original request around and match on
sequence number, as Pablo's patch's commit message suggests.

We're stuck with the current behavior by default, but we can add the
new ACK feature to deal with the issue in the long term.
