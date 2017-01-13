From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 2/2] mpls: Packet stats
Date: Fri, 13 Jan 2017 14:51:08 -0800
Message-ID: <587959DC.9020403@cumulusnetworks.com>
References: <1484331253-5908-1-git-send-email-rshearma@brocade.com> <1484331253-5908-3-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        David Ahern <dsa@cumulusnetworks.com>, ebiederm@xmission.com
To: Robert Shearman <rshearma@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:33327 "EHLO
        mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751496AbdAMWvK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 17:51:10 -0500
Received: by mail-pf0-f172.google.com with SMTP id y143so37606488pfb.0
        for <netdev@vger.kernel.org>; Fri, 13 Jan 2017 14:51:10 -0800 (PST)
In-Reply-To: <1484331253-5908-3-git-send-email-rshearma@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/13/17, 10:14 AM, Robert Shearman wrote:
> Having MPLS packet stats is useful for observing network operation and
> for diagnosing network problems. In the absence of anything better,
> RFC2863 and RFC3813 are used for guidance for which stats to expose
> and the semantics of them. In particular rx_noroutes maps to in
> unknown protos in RFC2863. The stats are exposed to userspace via
> AF_MPLS attributes embedded in the IFLA_STATS_AF_SPEC attribute of
> RTM_GETSTATS messages.
>
> All the introduced fields are 64-bit, even error ones, to ensure no
> overflow with long uptimes. Per-CPU counters are used to avoid
> cache-line contention on the commonly used fields. The other fields
> have also been made per-CPU for code to avoid performance problems in
> error conditions on the assumption that on some platforms the cost of
> atomic operations could be more expensive than sending the packet
> (which is what would be done in the success case). If that's not the
> case, we could instead not use per-CPU counters for these fields.
>
> Only unicast and non-fragment are exposed at the moment, but other
> counters can be exposed in the future either by adding to the end of
> struct mpls_link_stats or by additional netlink attributes in the
> AF_MPLS IFLA_STATS_AF_SPEC nested attribute.
>
> Signed-off-by: Robert Shearman <rshearma@brocade.com>
> ---
>
Acked-by: Roopa Prabhu <roopa@cumulusnetworks.com>
