From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH-update][RFC] net: consolidated UDP / UDP-Lite code
Date: Tue, 10 Oct 2006 19:38:28 -0700 (PDT)
Message-ID: <20061010.193828.10132678.davem@davemloft.net>
References: <20060727.223010.63131639.davem@davemloft.net>
	<200609190825.23709@strip-the-willow>
	<200610091051.45021@strip-the-willow>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:18310
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932408AbWJKCiZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Oct 2006 22:38:25 -0400
To: gerrit@erg.abdn.ac.uk
In-Reply-To: <200610091051.45021@strip-the-willow>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 9 Oct 2006 10:51:44 +0100

>  csum_copy_err:
> -	UDP_INC_STATS_BH(UDP_MIB_INERRORS);
> +	UDP_INC_STATS_BH(UDP_MIB_INERRORS, is_udplite);
> +	UDP_DEC_STATS_BH(UDP_MIB_INDATAGRAMS, is_udplite);

I'm not a big fan at all of these "statistic corrections"
we're starting to place in various spots.

I really don't think it's the end of the world if we count as
INDATAGRAMS a packet that we later discover has a bad checksum.

There are even some serious issues to consider because we might,
for example, count the INDATAGRAMS on a particular cpu, and then
find the checksum problem on another cpu and thus be subtracting
a different one of the per-cpu instances of this counter.  That
could make it negative or similar.
