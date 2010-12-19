From: Matt Domsch <Matt_Domsch@dell.com>
Subject: Re: [PATCH net-next] bnx2x: Add Nic partitioning mode (57712 devices)
Date: Sat, 18 Dec 2010 23:57:31 -0600
Message-ID: <20101219055731.GD5854@auslistsprd01.us.dell.com>
References: <1290982177.6066.3.camel@lb-tlvb-dmitry> <20101129060114.GC29904@auslistsprd01.us.dell.com> <1291023192.9770.0.camel@lb-tlvb-eilong.il.broadcom.com> <20101206173534.GC13628@auslistsprd01.us.dell.com> <4CFD29BE.2060201@chelsio.com> <1291906166.21210.10.camel@lb-tlvb-eilong.il.broadcom.com> <20101217024509.GA5854@auslistsprd01.us.dell.com> <1292592157.3136.819.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eilon Greenstein <eilong@broadcom.com>,
	Dimitris Michailidis <dm@chelsio.com>,
	Dmitry Kravkov <dmitry@broadcom.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"narendra_k@dell.com" <narendra_k@dell.com>,
	"jordan_hargrave@dell.com" <jordan_hargrave@dell.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausc60ps301.us.dell.com ([143.166.148.206]:7355 "EHLO
	ausc60ps301.us.dell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750816Ab0LSF5d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Dec 2010 00:57:33 -0500
Content-Disposition: inline
In-Reply-To: <1292592157.3136.819.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 17, 2010 at 01:22:37PM +0000, Ben Hutchings wrote:
> On Thu, 2010-12-16 at 20:45 -0600, Matt Domsch wrote:
> > On Thu, Dec 09, 2010 at 04:49:25PM +0200, Eilon Greenstein wrote:
> In the case of sfc, each port has a separate PCI function.  We read this
> register field to find out which port we're talking to, as
> virtualisation can alter the function number.  I don't know about the
> others.

For a single card then, this makes sense.

pci<slot>#<port>  where port = dev_id

If I have 2 such cards on a PCI extender though, I think this breaks.
Here, I'd see duplicate dev_id values, yes?

Do you label the ports on your cards in any fashion?  Do they have
labels like port 0, port 1, port 2, ... ?  Does it matter if we give
names starting at 0, or starting at 1?  latest biosdevname starts them
at 1, or uses whatever value BIOS actually provides, which on systems
I've tried, all start at 1.

Maybe the PCI extender case I should just ignore as being unsolvable
right now...  If I think N PCI devices are in the same slot, then
using the dev_id value as a per-slot value is fine.  If there's an
extender that would break this scheme, biosdevname now returns nothing
for any names it would otherwise suggest duplicate names for,
essentially throwing its hands up "I don't know".

-- 
Matt Domsch
Technology Strategist
Dell | Office of the CTO
