From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 1/2] net: AF-specific RTM_GETSTATS attributes
Date: Fri, 13 Jan 2017 14:50:35 -0800
Message-ID: <587959BB.4000000@cumulusnetworks.com>
References: <1484331253-5908-1-git-send-email-rshearma@brocade.com> <1484331253-5908-2-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        David Ahern <dsa@cumulusnetworks.com>, ebiederm@xmission.com
To: Robert Shearman <rshearma@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:33230 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751232AbdAMWuh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 17:50:37 -0500
Received: by mail-pf0-f181.google.com with SMTP id y143so37600921pfb.0
        for <netdev@vger.kernel.org>; Fri, 13 Jan 2017 14:50:37 -0800 (PST)
In-Reply-To: <1484331253-5908-2-git-send-email-rshearma@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/13/17, 10:14 AM, Robert Shearman wrote:
> Add the functionality for including address-family-specific per-link
> stats in RTM_GETSTATS messages. This is done through adding a new
> IFLA_STATS_AF_SPEC attribute under which address family attributes are
> nested and then the AF-specific attributes can be further nested. This
> follows the model of IFLA_AF_SPEC on RTM_*LINK messages and it has the
> advantage of presenting an easily extended hierarchy. The rtnl_af_ops
> structure is extended to provide AFs with the opportunity to fill and
> provide the size of their stats attributes.
>
> One alternative would have been to provide AFs with the ability to add
> attributes directly into the RTM_GETSTATS message without a nested
> hierarchy. I discounted this approach as it increases the rate at
> which the 32 attribute number space is used up and it makes
> implementation a little more tricky for stats dump resuming (at the
> moment the order in which attributes are added to the message has to
> match the numeric order of the attributes).
>
> Another alternative would have been to register per-AF RTM_GETSTATS
> handlers. I discounted this approach as I perceived a common use-case
> to be getting all the stats for an interface and this approach would
> necessitate multiple requests/dumps to retrieve them all.
>
> Signed-off-by: Robert Shearman <rshearma@brocade.com>
>
Acked-by: Roopa Prabhu <roopa@cumulusnetworks.com>
