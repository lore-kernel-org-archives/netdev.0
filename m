From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 0/3 net-next] Bring sizeof(net_device) down to < 2K bytes
Date: Fri, 10 Apr 2015 09:41:34 +0100
Message-ID: <20150410084134.GA23070@casper.infradead.org>
References: <cover.1428622095.git.tgraf@suug.ch>
 <20150410000151.GA1728@Alexeis-MBP.westell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	eric.dumazet@gmail.com
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:60531 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932274AbbDJIlj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Apr 2015 04:41:39 -0400
Content-Disposition: inline
In-Reply-To: <20150410000151.GA1728@Alexeis-MBP.westell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/09/15 at 05:01pm, Alexei Starovoitov wrote:
> On Fri, Apr 10, 2015 at 01:43:25AM +0200, Thomas Graf wrote:
> > The size of struct net_device crossed the 2K boundary a while ago which
> > is a waste in combination with many net namespaces. This series brings
> > the size of struct net_device down to well below 2K in total size with
> > a typical configuration. Some reserves a several holes leave room for
> > further expansion.
> 
> Great stuff!
> Can you share what was the sizeof(struct net_device) with typical
> x86 config before and after?

Before:

/* BRAIN FART ALERT! 2176 != 2091 + 41(holes), diff = 44 */

After:

/* size: 1984, cachelines: 31, members: 121 */
/* sum members: 1947, holes: 6, sum holes: 33 */
/* padding: 8 */
/* paddings: 2, sum paddings: 11 */

/* BRAIN FART ALERT! 1984 != 1947 + 33(holes), diff = 4 */
