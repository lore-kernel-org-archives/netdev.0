From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 1/2] mpls: packet stats
Date: Thu, 28 Jul 2016 22:19:56 -0700
Message-ID: <579AE77C.5040901@cumulusnetworks.com>
References: <1454700472-13543-1-git-send-email-rshearma@brocade.com> <1454700472-13543-2-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: Robert Shearman <rshearma@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:33348 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750752AbcG2FT7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jul 2016 01:19:59 -0400
Received: by mail-pa0-f52.google.com with SMTP id ks6so27745476pab.0
        for <netdev@vger.kernel.org>; Thu, 28 Jul 2016 22:19:59 -0700 (PDT)
In-Reply-To: <1454700472-13543-2-git-send-email-rshearma@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/5/16, 11:27 AM, Robert Shearman wrote:
> Having MPLS packet stats is useful for observing network operation and
> for diagnosing network problems. In the absence of anything better,
> use RFCs for MIBs defining MPLS stats for guidance on the semantics of
> the stats to expose. RFC3813 details two per-interface packet stats
> that should be provided (label lookup failures and fragmented packets)
> and also provides interpretation of RFC2863 for other per-interface
> stats (in/out ucast, mcast and bcast, in/out discards and errors and
> in unknown protos).
>
> Multicast, fragment and broadcast packet counters are printed, but not
> stored to allow for future implementation of current standards or
> future standards without user-space having to change.
>
> All the introduced fields are 64-bit, even error ones, to ensure no
> overflow with long uptimes. Per-CPU counters are used to avoid
> cache-line contention on the commonly used fields. The other fields
> have also been made per-CPU for code to avoid performance problems in
> error conditions on the assumption that on some platforms the cost of
> atomic operations could be more pexpensive than sending the packet
> (which is what would be done in the success case). If that's not the
> case, we could instead not use per-CPU counters for these fields.
>
> The IPv6 proc code was used as an inspiration for the proc code
> here, both in terms of the implementation as well as the location of
> the per-device stats proc files: /proc/net/dev_snmp_mpls/<dev>.
>
> Signed-off-by: Robert Shearman <rshearma@brocade.com>
>
Robert, any interest in moving this to the new stats api ?.

I had done some work for AF_<family> stats. Did not eventually end up including it in the
final version. The AF_<family> infra patch is here:
https://github.com/CumulusNetworks/net-next/commits/mpls-stats

Thanks!.
