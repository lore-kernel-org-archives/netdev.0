From: Stephen Hemminger <shemming@brocade.com>
Subject: Re: [PATCH v2 iproute2] tc: f_u32: Add support for skip_hw and
 skip_sw flags
Date: Wed, 8 Jun 2016 16:46:59 -0700
Message-ID: <20160608164659.695ce9c5@xeon-e3>
References: <1465427761-7038-1-git-send-email-sridhar.samudrala@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <john.r.fastabend@intel.com>, <jakub.kicinski@netronome.com>,
	<netdev@vger.kernel.org>
To: Sridhar Samudrala <sridhar.samudrala@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:34636 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751876AbcFHXqt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2016 19:46:49 -0400
In-Reply-To: <1465427761-7038-1-git-send-email-sridhar.samudrala@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 8 Jun 2016 16:16:01 -0700
Sridhar Samudrala <sridhar.samudrala@intel.com> wrote:

> On devices that support TC U32 offloads, these flags enable a filter to be
> added only to HW or only to SW. skip_sw and skip_hw are mutually exclusive
> flags. By default without any flags, the filter is added to both HW and SW,
> but no error checks are done in case of failure to add to HW.
> With skip-sw, failure to add to HW is treated as an error.
> 
> Here is a sample script that adds 2 filters, one with skip_sw and the other
> with skip_hw flag.
> 
>    # add ingress qdisc
>    tc qdisc add dev p4p1 ingress
> 
>    # enable hw tc offload.
>    ethtool -K p4p1 hw-tc-offload on
> 
>    # add u32 filter with skip-sw flag.
>    tc filter add dev p4p1 parent ffff: protocol ip prio 99 \
>       handle 800:0:1 u32 ht 800: flowid 800:1 \
>       skip-sw \
>       match ip src 192.168.1.0/24 \
>       action drop
> 
>    # add u32 filter with skip-hw flag.
>    tc filter add dev p4p1 parent ffff: protocol ip prio 99 \
>       handle 800:0:2 u32 ht 800: flowid 800:2 \
>       skip-hw \
>       match ip src 192.168.2.0/24 \
>       action drop
> 
> Signed-off-by: Sridhar Samudrala <sridhar.samudrala@intel.com>

Applied, then updated, already needed to cleanup some style issues in f_u32 anyway.
