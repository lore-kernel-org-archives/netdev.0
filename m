From: Mike Galbraith <efault@gmx.de>
Subject: Re: [tbench regression fixes]: digging out smelly deadmen.
Date: Sun, 26 Oct 2008 11:23:19 +0100
Message-ID: <1225016599.5403.15.camel@marge.simson.net>
References: <20081024.221653.23695396.davem@davemloft.net>
	 <1224914333.3822.18.camel@marge.simson.net>
	 <1224917623.4929.15.camel@marge.simson.net>
	 <20081025.002420.82739316.davem@davemloft.net>
	 <Pine.LNX.4.64.0810260055070.22126@twin.jikos.cz>
	 <1225010790.8566.22.camel@marge.simson.net>
	 <1225011648.27415.4.camel@twins>
	 <20081026021153.47878580.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Jiri Kosina <jkosina@suse.cz>,
	David Miller <davem@davemloft.net>, rjw@sisk.pl,
	Ingo Molnar <mingo@elte.hu>, s0mbre@tservice.net.ru,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:36730 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751137AbYJZKXb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 26 Oct 2008 06:23:31 -0400
In-Reply-To: <20081026021153.47878580.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2008-10-26 at 02:11 -0700, Andrew Morton wrote:

> Was this when we decreased the default value of
> /proc/sys/vm/dirty_ratio, perhaps?  dbench is sensitive to that.

Wow, indeed.  I fired up an ext2 disk to take kjournald out of the
picture (dunno, just a transient thought).  Stock settings produced
three perma-wrecks in a row.  With it bumped to 50, three very
considerably nicer results in a row appeared.

=EF=BB=BF2.6.26.7-smp dirty_ratio =3D 10 (stock)
Throughput 36.3649 MB/sec 160 procs
Throughput 47.0787 MB/sec 160 procs
Throughput 88.2055 MB/sec 160 procs

2.6.26.7-smp dirty_ratio =3D 50
Throughput 1009.98 MB/sec 160 procs
Throughput 1101.57 MB/sec 160 procs
Throughput 943.205 MB/sec 160 procs
=EF=BB=BF
	-Mike

