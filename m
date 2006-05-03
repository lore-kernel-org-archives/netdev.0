From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: VJ Channel API - driver level (PATCH)
Date: Wed, 3 May 2006 11:49:23 -0700
Message-ID: <20060503114923.47020f26@localhost.localdomain>
References: <54AD0F12E08D1541B826BE97C98F99F149E8B4@NT-SJCA-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Evgeniy Polyakov" <johnpol@2ka.mipt.ru>,
	"Leonid Grossman" <Leonid.Grossman@neterion.com>,
	"David S. Miller" <davem@davemloft.net>, alex@neterion.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:32155 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750728AbWECStn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 May 2006 14:49:43 -0400
To: "Caitlin Bestler" <caitlinb@broadcom.com>
In-Reply-To: <54AD0F12E08D1541B826BE97C98F99F149E8B4@NT-SJCA-0751.brcm.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 3 May 2006 11:12:15 -0700
"Caitlin Bestler" <caitlinb@broadcom.com> wrote:

> Evgeniy Polyakov wrote:
> > On Wed, May 03, 2006 at 08:56:23AM -0700, Caitlin Bestler
> > (caitlinb@broadcom.com) wrote:
> >>> I'd expect high end NIC ASICs to implement rx steering based upon
> >>> some sort of hash (for load balancing), as well as explicit "1:1"
> >>> steering between a sw channel and a hw channel. Both options for
> >>> channel configuration are present in the driver interface.
> >>> If netfilter assists can be done in hardware, I agree the driver
> >>> interface will need to add support for these - otherwise, netfilter
> >>> processing will stay above the driver.
> >>> 
> >>> 
> >> 
> >> Even if the hardware cannot fully implement netfilter rules there is
> >> still value in having an interface that documents exactly how much
> >> filtering a given piece of hardware can do.
> >> There is no point in having the kernel repeat packet classifications
> >> that have already been done by the NIC.
> > 
> > Please do not suppose that vj channel must rely on
> > underlaying hardware.
> > New interface MUST work better or at least not worse than
> > existing skb queueing for majority of users, and I doubt
> > users with netfilter capable hardware are there.
> > It is only some hint to the SW, not rules, that hardware can provide.
> > The best would be ipv4/ipv6 hashing, and I think it is enough.
> 
> I agree. I was just stating that *if* there is direct hardware 
> support then the software should be enabled to skip 
> redundant checks. What I'm suggesting is really the
> equivalent of knowing whether the hardware generates
> or checks CRCs and TCP checksums. Don't mandate
> the feature, just have the option to avoid redundant work.
> 

Also like mulitcast filtering, you need to allow for the partial
match case. If hardware can do some of the work, it is helps.
