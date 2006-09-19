From: David Miller <davem@davemloft.net>
Subject: Re: Network performance degradation from 2.6.11.12 to 2.6.16.20
Date: Tue, 19 Sep 2006 12:40:34 -0700 (PDT)
Message-ID: <20060919.124034.78165098.davem@davemloft.net>
References: <20060918211759.GB31746@tentacle.sectorb.msk.ru>
	<20060918220038.GB14322@ms2.inr.ac.ru>
	<Pine.LNX.4.63.0609181452470.14338@qynat.qvtvafvgr.pbz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, master@sectorb.msk.ru, ak@suse.de,
	hawk@diku.dk, harry@atmos.washington.edu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751998AbWISTkb@vger.kernel.org>
To: dlang@digitalinsight.com
In-Reply-To: <Pine.LNX.4.63.0609181452470.14338@qynat.qvtvafvgr.pbz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Lang <dlang@digitalinsight.com>
Date: Mon, 18 Sep 2006 14:57:04 -0700 (PDT)

> yes tcpdump may be wrong in requesting timestamps (in most cases it
> probably is, but in some cases it's doing exactly what the sysadmin
> wants it to do), but I don't think that many sysadmins would expect
> this much of a performance hit.  there should be some way to tell
> the system to ignore requests for timestamps so that a badly behaved
> program cannot cripple the system this way (and preferably something
> that doesn't require a full SELinux/capabilities implementation)

tcpdump is not wrong in requesting timestamps, and there are
many legitimate userland programs that call gettimeofday()
for internal timestamping _A LOT_.  Such as X11 clients.

The real fact of the matter is that these x86_64 systems are using the
slowest possible time-of-day implementation, simply because it's "too
hard" currently to properly probe the most efficient mechanism which
is present in the system.

If getting the time of day is at the top of the profiles in the packet
input path, and we're only capturing a timestamp once per packet,
something is _VERY VERY_ wrong with the timestamp implementation
because think of all of the other seriously expensive things that
happen on a per-packet basis which should absolutely dwarf
timestamping in terms of cost.
