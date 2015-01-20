From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [Xen-devel] [RFC PATCHv1 net-next] xen-netback: always fully
 coalesce guest Rx packets
Date: Tue, 20 Jan 2015 11:23:13 +0000
Message-ID: <1421752993.10440.225.camel@citrix.com>
References: <1421157917-31333-1-git-send-email-david.vrabel@citrix.com>
	 <20150113143033.GN4226@zion.uk.xensource.com> <54BD408A.6080405@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Wei Liu <wei.liu2@citrix.com>, <netdev@vger.kernel.org>,
	<xen-devel@lists.xenproject.org>,
	Jonathan Davies <jonathan.davies@citrix.com>
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:59100 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753584AbbATLXQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2015 06:23:16 -0500
In-Reply-To: <54BD408A.6080405@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-01-19 at 17:36 +0000, David Vrabel wrote:
> On 13/01/15 14:30, Wei Liu wrote:
> > On Tue, Jan 13, 2015 at 02:05:17PM +0000, David Vrabel wrote:
> >> Always fully coalesce guest Rx packets into the minimum number of ring
> >> slots.  Reducing the number of slots per packet has significant
> >> performance benefits (e.g., 7.2 Gbit/s to 11 Gbit/s in an off-host
> >> receive test).
> >>
> > 
> > Good number.
> > 
> >> However, this does increase the number of grant ops per packet which
> >> decreases performance with some workloads (intrahost VM to VM)
> > 
> > Do you have figures before and after this change?
> 
> Some better (more rigorous) results done by Jonathan Davies shows no
> regressions with full coalescing even without the grant copy
> optimization, and a big improvement to single stream receive.
> 
>                          baseline    Full coalesce
> Interhost aggregate      24 Gb/s     24 Gb/s
> Interhost VM receive      7.2 Gb/s   11 Gb/s
> Intrahost single stream  14 Gb/s     14 Gb/s
> Intrahost aggregate      34 Gb/s     34 Gb/s

Do you have a third column to hand, for Full-coalesce w/ grant copy
optimisation case? (Don't worry if not)

Ian.
