From: "Simon Barber" <simon@devicescape.com>
Subject: RE: [patch] d80211: use pfifo_qdisc_ops rather than d80211-specific qdisc
Date: Wed, 25 Oct 2006 22:15:23 -0700
Message-ID: <C86180A8C204554D8A3323D8F6B0A29F018B54FB@dhost002-46.dex002.intermedia.net>
References: <20061026050416.GB14199@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Patrick McHardy" <kaber@trash.net>,
	"David Kimdon" <dwhedon@devicescape.com>, <netdev@vger.kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	"Jiri Benc" <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-46.dex002.intermedia.net ([64.78.21.140]:796 "EHLO
	dhost002-46.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S1423398AbWJZFPK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2006 01:15:10 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20061026050416.GB14199@havoc.gtf.org>
To: "Jeff Garzik" <jeff@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Re: registering as a real protocol - yes this I have been going on about
for a while. This needs a few changes in how things work:

1. Register as a real protocol.
2. Change drivers to use netif_rx to receive frames (will also be more
efficient)

I would also like to see:

Drivers to use register_netdev - not special ieee80211 register to
register themselves
Drivers to use a normal hard_start_xmit function
- need to move 802.11 pre xmit frame processing into the qdisc dequeue
function
Get rid of gunky beacon & multicast buffered frame handling - make them
into normal queues like everything else (so same hard_start_xmit can be
used).

Simon


-----Original Message-----
From: Jeff Garzik [mailto:jeff@garzik.org] 
Sent: Wednesday, October 25, 2006 10:04 PM
To: Simon Barber
Cc: Patrick McHardy; David Kimdon; netdev@vger.kernel.org; John W.
Linville; Jiri Benc
Subject: Re: [patch] d80211: use pfifo_qdisc_ops rather than
d80211-specific qdisc

On Wed, Oct 25, 2006 at 08:37:04PM -0700, Simon Barber wrote:
> Doing this will slow down the qdisc - it does already run an external 
> classifier first if you install one. On typical laptops performance is

> not a problem, but one common usage does have problems. The 
> performance of a wireless home gateway based on a simple linux kernel 
> configuration (NAT, iptables, bridging) is significantly slower than a

> VxWorks based one. With the arrival of 802.11n improving the 
> performance of the stack is very important. The VxWorks solution may 
> be less flexible in terms of what it can do, but it will allow the 
> full 802.11n bandwidth to be achieved on slower embedded CPUs than 
> Linux does. How to improve the linux kernel networking to improve it's

> efficiency here is a hard problem.

First do it right, then tune performance.  If you aren't doing it right,
then who cares about VxWorks.

We also need 802.11 to register as a real protocol, rather than faking
ethernet.  David Miller did an example stub:
http://www.kernel.org/pub/linux/kernel/people/jgarzik/patchkits/2.6/dave
m-p80211.tar.bz2

	Jeff



