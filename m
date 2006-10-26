From: "Simon Barber" <simon@devicescape.com>
Subject: RE: [patch] d80211: use pfifo_qdisc_ops rather than d80211-specific qdisc
Date: Wed, 25 Oct 2006 20:37:04 -0700
Message-ID: <C86180A8C204554D8A3323D8F6B0A29F018B54F4@dhost002-46.dex002.intermedia.net>
References: <20061026023838.GA6032@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "David Kimdon" <dwhedon@devicescape.com>, <netdev@vger.kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	"Jiri Benc" <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-46.dex002.intermedia.net ([64.78.21.140]:8906 "EHLO
	dhost002-46.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S1422914AbWJZDgv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2006 23:36:51 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20061026023838.GA6032@havoc.gtf.org>
To: "Jeff Garzik" <jeff@garzik.org>,
	"Patrick McHardy" <kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Doing this will slow down the qdisc - it does already run an external
classifier first if you install one. On typical laptops performance is
not a problem, but one common usage does have problems. The performance
of a wireless home gateway based on a simple linux kernel configuration
(NAT, iptables, bridging) is significantly slower than a VxWorks based
one. With the arrival of 802.11n improving the performance of the stack
is very important. The VxWorks solution may be less flexible in terms of
what it can do, but it will allow the full 802.11n bandwidth to be
achieved on slower embedded CPUs than Linux does. How to improve the
linux kernel networking to improve it's efficiency here is a hard
problem.

Simon


-----Original Message-----
From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
On Behalf Of Jeff Garzik
Sent: Wednesday, October 25, 2006 7:39 PM
To: Patrick McHardy
Cc: David Kimdon; netdev@vger.kernel.org; John W. Linville; Jiri Benc
Subject: Re: [patch] d80211: use pfifo_qdisc_ops rather than
d80211-specific qdisc

On Thu, Oct 26, 2006 at 03:21:10AM +0200, Patrick McHardy wrote:
> Considering that it is possibly and may be desirable to attach a 
> different qdisc than the built-in multiband qdisc, it might also make 
> sense to split the 80211 specific classification in a seperate 
> classifier module to allow simple classification of management traffic

> with other qdiscs.

I've been telling the wireless people this for ages...

	Jeff



-
To unsubscribe from this list: send the line "unsubscribe netdev" in the
body of a message to majordomo@vger.kernel.org More majordomo info at
http://vger.kernel.org/majordomo-info.html
