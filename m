From: Tom Herbert <tom@herbertland.com>
Subject: Re: Add support for Geneve udp port offload
Date: Fri, 4 Dec 2015 08:31:28 -0800
Message-ID: <CALx6S37N95yGGZs49KcF1D2VDknx2S+Wo1PgfwQz=KFQqznOAA@mail.gmail.com>
References: <1449217144-18756-1-git-send-email-anjali.singhai@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Anjali Singhai Jain <anjali.singhai@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f174.google.com ([209.85.223.174]:33883 "EHLO
	mail-io0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755056AbbLDQb3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Dec 2015 11:31:29 -0500
Received: by ioir85 with SMTP id r85so121273336ioi.1
        for <netdev@vger.kernel.org>; Fri, 04 Dec 2015 08:31:28 -0800 (PST)
In-Reply-To: <1449217144-18756-1-git-send-email-anjali.singhai@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 4, 2015 at 12:19 AM, Anjali Singhai Jain
<anjali.singhai@intel.com> wrote:
> This patch series adds new ndo ops for Geneve add/del port, so as
> to help offload Geneve tunnel functionalities such as checksum, TSO
> RSS, filters etc.
>
> i40e driver has been tested with the changes to make sure the offloads
> happen.
>
> We do understand that this is not the ideal solution and most likely
> will be redone with a more generic offload framework.
> But this certainly will enable us to start seeing benefits of the
> accelerations for Geneve tunnels.
>
Anjali,

This is a lot of complexity being added to i40e driver and kernel. It
needs to be justified. Please:

1) Quantify the effects of the offloads. Please provide a set of
performance numbers for various benchmarks showing tps, CPU, latency,
etc. You can peruse some of the patches I have done for GUE or VXLAN
for ideas on reporting performance.
2) The baselines for the above testing should include UDP checksum
enabled with Remote Checksum Offload and GRO/GSO in full effect. I
don't know if RCO has been implemented for Geneve, but it should be
pretty straightforward to add if it's not.
3) The ndo function needs to be clearly documented. Precisely what is
a driver allowed to do with this port information? We already have at
least one case in VXLAN where a driver is incorrectly using the
provide port in the transmit path, this should be explicitly forbidden
in the description.

Thanks,
Tom

> As a side note, we did find an existing issue in i40e driver where a
> service task can modify tunnel data structures with no locks held to
> help linearize access. A separate patch will be taking care of that issue.
>
> A question out to the community is regarding the driver Kconfig parameters
> for VxLAN and Geneve, it would be ideal to drop those if there is a way
> to help resolve vxlan/geneve_get_rx_port symbols while the tunnel modules
> are not loaded.
>
> Anjali Singhai Jain (4):
>   [RFC PATCH v2 1/4] geneve: Add geneve udp port offload for ethernet
>   [RFC PATCH v2 2/4] i40e: geneve tunnel offload support
>   [RFC PATCH v2 3/4] i40e: Kernel dependency update for i40e to support
>   [RFC PATCH v2 4/4] geneve: Add geneve_get_rx_port support
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
