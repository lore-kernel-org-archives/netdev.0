From: Bill Fink <billfink@mindspring.com>
Subject: Re: [PATCH 2/3][NET_BATCH] net core use batching
Date: Mon, 1 Oct 2007 00:11:35 -0400
Message-ID: <20071001001135.75d2b984.billfink@mindspring.com>
References: <20070914090058.17589.80352.sendpatchset@K50wks273871wss.in.ibm.com>
	<20070916.161748.48388692.davem@davemloft.net>
	<1189988958.4230.55.camel@localhost>
	<1190569987.4256.52.camel@localhost>
	<1190570205.4256.56.camel@localhost>
	<1190570317.4256.59.camel@localhost>
	<1190570409.4256.62.camel@localhost>
	<1191178346.6165.29.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, krkumar2@in.ibm.com,
	johnpol@2ka.mipt.ru, herbert@gondor.apana.org.au, kaber@trash.net,
	shemminger@linux-foundation.org, jagana@us.ibm.com,
	Robert.Olsson@data.slu.se, rick.jones2@hp.com, xma@us.ibm.com,
	gaagaan@gmail.com, netdev@vger.kernel.org, rdreier@cisco.com,
	peter.p.waskiewicz.jr@intel.com, mcarlson@broadcom.com,
	jeff@garzik.org, mchan@broadcom.com, general@lists.openfabrics.org,
	kumarkr@linux.ibm.com, tgraf@suug.ch, randy.dunlap@oracle.com,
	sri@us.ibm.com
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-curtail.atl.sa.earthlink.net ([209.86.89.64]:43848 "EHLO
	elasmtp-curtail.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750956AbXJAENZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2007 00:13:25 -0400
In-Reply-To: <1191178346.6165.29.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 30 Sep 2007, jamal wrote:

> This patch adds the usage of batching within the core.
> 
> cheers,
> jamal



> [sep30-p2of3  text/plain (6.8KB)]
> [NET_BATCH] net core use batching
> 
> This patch adds the usage of batching within the core.
> The same test methodology used in introducing txlock is used, with
> the following results on different kernels:
> 
>         +------------+--------------+-------------+------------+--------+
>         |       64B  |  128B        | 256B        | 512B       |1024B   |
>         +------------+--------------+-------------+------------+--------+
> Original| 467482     | 463061       | 388267      | 216308     | 114704 |
>         |            |              |             |            |        |
> txlock  | 468922     | 464060       | 388298      | 216316     | 114709 |
>         |            |              |             |            |        |
> tg3nobtx| 468012     | 464079       | 388293      | 216314     | 114704 |
>         |            |              |             |            |        |
> tg3btxdr| 480794     | 475102       | 388298      | 216316     | 114705 |
>         |            |              |             |            |        |
> tg3btxco| 481059     | 475423       | 388285      | 216308     | 114706 |
>         +------------+--------------+-------------+------------+--------+
> 
> The first two colums "Original" and "txlock" were introduced in an earlier
> patch and demonstrate a slight increase in performance with txlock.
> "tg3nobtx" shows the tg3 driver with no changes to support batching.
> The purpose of this test is to demonstrate the effect of introducing
> the core changes to a driver that doesnt support them.
> Although this patch brings down perfomance slightly compared to txlock
> for such netdevices, it is still better compared to just the original
> kernel.
> "tg3btxdr" demonstrates the effect of using ->hard_batch_xmit() with tg3
> driver. "tg3btxco" demonstrates the effect of letting the core do all the
> work. As can be seen the last two are not very different in performance.
> The difference is ->hard_batch_xmit() introduces a new method which
> is intrusive.

Have you done performance comparisons for the case of using 9000-byte
jumbo frames?

						-Bill
