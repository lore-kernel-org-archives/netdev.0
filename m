From: Toshiaki Makita <toshiaki.makita1@gmail.com>
Subject: Re: [PATCH v3 net 2/9] bridge: Fix the way to insert new local fdb
 entries in br_fdb_changeaddr
Date: Sat, 08 Feb 2014 11:43:48 +0900
Message-ID: <1391827428.1739.22.camel@localhost.localdomain>
References: <1391759306-24956-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
	 <1391759306-24956-3-git-send-email-makita.toshiaki@lab.ntt.co.jp>
	 <20140207093127.56f78187@samsung-9>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	"David S . Miller" <davem@davemloft.net>,
	Vlad Yasevich <vyasevic@redhat.com>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:35318 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750756AbaBHCny (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Feb 2014 21:43:54 -0500
Received: by mail-pa0-f41.google.com with SMTP id fa1so3964726pad.28
        for <netdev@vger.kernel.org>; Fri, 07 Feb 2014 18:43:53 -0800 (PST)
In-Reply-To: <20140207093127.56f78187@samsung-9>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-02-07 at 09:31 -0700, Stephen Hemminger wrote:
> On Fri,  7 Feb 2014 16:48:19 +0900
> Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp> wrote:
> 
> > Since commit bc9a25d21ef8 ("bridge: Add vlan support for local fdb entries"),
> > br_fdb_changeaddr() has inserted a new local fdb entry only if it can
> > find old one. But if we have two ports where they have the same address
> > or user has deleted a local entry, there will be no entry for one of the
> > ports.
> > 
> > Example of problematic case:
> >   ip link set eth0 address aa:bb:cc:dd:ee:ff
> >   ip link set eth1 address aa:bb:cc:dd:ee:ff
> >   brctl addif br0 eth0
> >   brctl addif br0 eth1 # eth1 will not have a local entry due to dup.
> 
> I think the second addif should fail, it doesn't seem valid to have
> two interfaces on same bridge with same address. Most hardware switches
> would disable the port in that case.

Thank you for your comment, but I don't think so for several reasons.

- From other network elements on the same network, bridge ports don't
appear to have a mac address, but the bridge appears to have several mac
addresses that can reach to the bridge. The duplicated address is simply
seen as one of those addresses. I don't think it is a problem.

- This operation (add a port that has duplicated address) has allowed
for several years, and it is obviously intended, as commented in
fdb_insert().

417                 /* it is okay to have multiple ports with same
418                  * address, just use the first one.
419                  */

- Hardware switches usually have one mac address per one switch. Their
ports don't have mac addresses. It is not reasonable to compare hardware
switches.

Thanks,
Toshiaki Makita
