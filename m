From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next] net: ipmr: add getlink support
Date: Wed, 7 Jun 2017 10:44:38 +0300
Message-ID: <5793a3a8-8a7b-438c-a6b4-3c42271fe06d@cumulusnetworks.com>
References: <1496767292-7976-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: roopa@cumulusnetworks.com, davem@davemloft.net,
        sharpd@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f179.google.com ([209.85.128.179]:36546 "EHLO
        mail-wr0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751003AbdFGHol (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Jun 2017 03:44:41 -0400
Received: by mail-wr0-f179.google.com with SMTP id v111so2194948wrc.3
        for <netdev@vger.kernel.org>; Wed, 07 Jun 2017 00:44:40 -0700 (PDT)
In-Reply-To: <1496767292-7976-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/06/17 19:41, Nikolay Aleksandrov wrote:
> Currently there's no way to dump the VIF table for an ipmr table other
> than the default (via proc). This is a major issue when debugging ipmr
> issues and in general it is good to know which interfaces are
> configured. This patch adds support for RTM_GETLINK for the ipmr family
> so we can dump the VIF table and the ipmr table's current config for
> each table. We're protected by rtnl so no need to acquire RCU or
> mrt_lock.
> 
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> ---
> The plan is to add full netlink control to ipmr via new/set/dellink later.
> Also this would allow us to dump any number of VIFs in the future when we
> remove the VIF device limit.
> 
>  include/uapi/linux/mroute.h |  38 +++++++++++++++
>  net/ipv4/ipmr.c             | 114 ++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 152 insertions(+)
> 

Self-NAK, after discussing this further with Roopa, I think it'll be best if we turn all of
these table and vif options into embedded separate netlink attributes. We'll get all the
netlink benefits and it will be much easier for user-space to manipulate them later.

Will send v2 later after some testing.

Thanks,
 Nik
