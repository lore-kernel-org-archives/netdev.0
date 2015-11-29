From: Stephen Hemminger <shemming@brocade.com>
Subject: Re: [iproute PATCH v3 0/5] flush many addresses and some cleanups
Date: Sun, 29 Nov 2015 11:50:54 -0800
Message-ID: <20151129115054.324a70be@xeon-e3>
References: <20151123163115.5f8be482@xeon-e3>
	<1448375464-12145-1-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:5835 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752258AbbK2Tu7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Nov 2015 14:50:59 -0500
In-Reply-To: <1448375464-12145-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 24 Nov 2015 15:30:59 +0100
Phil Sutter <phil@nwl.cc> wrote:

> This patch series aims to silence spurious error messages when flushing
> an interface with many addresses assigned and provides a few cleanups
> found along the way.
> 
> The original issue was a test-case adding 40k IPv4 addresses to an
> interface and calling 'ip addr flush' afterwards. Initially, this
> resulted in an error message:
> 
> | Failed to send flush request: Cannot assign requested address
> 
> Iproute apparently tried to remove (secondary) addresses which didn't
> exist anymore since the primary one had already been removed. (This
> behaviour actually depends on the promote_secondaries sysctl setting.)
> Neil Horman fixed this issue in his recent patch e149d4e ("iproute2:
> Ignore EADDRNOTAVAIL errors during address flush operation"). This also
> allows to remove iproute's previous workaround, which is to flush
> secondary addresses before primary ones (patch 1/5).
> 
> Yet, still an error message is emitted on newer kernels, as they started
> to check consistency of netlink dumps (which is broken by iproute as it
> alters the data while it is dumped). This error may as well be ignored,
> as it's expected behaviour while flushing addresses. Though in order to
> do that, libnetlink API had to be extended a bit to actually allow to
> ignore certain nlmsg_flags bits. Patch 2/5 therefore extends libnetlink,
> patch 3/5 then makes use of the extended functionality.
> 
> While debugging the issue, an unnecessary check has been discovered
> (patch 4/5) as well as a possible simplification in iptoken.c was found
> (patch 5/5).
> 
> Changes since v1:
> - Add forgotten hint about dependent patch (see above).
> - Fix typo in patch 3/6 (sorry, I forgot to test-build a last-minute
>   cleanup).
> - All other patches remain unchanged.
> 
> Changes since v2:
> - Drop first patch since it was superseded by e149d4e ("iproute2:
>   Ignore EADDRNOTAVAIL errors during address flush operation").
> - Adjust cover letter text accordingly.
> 
> Phil Sutter (5):
>   ipaddress: simplify ipaddr_flush()
>   libnetlink: introduce nc_flags
>   ipaddress: fix ipaddr_flush for Linux >= 3.1
>   ipaddress: drop unnecessary check in ipaddr_list_flush_or_save()
>   iptoken: simplify iptoken_list a bit
> 
>  include/libnetlink.h |  7 ++++++-
>  ip/ipaddress.c       | 44 +++-----------------------------------------
>  ip/iptoken.c         |  6 +-----
>  lib/libnetlink.c     | 10 ++++++----
>  4 files changed, 16 insertions(+), 51 deletions(-)
>

Applied, thanks
