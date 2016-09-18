From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [net-next PATCH] net: netlink messages for HW addr programming
Date: Sun, 18 Sep 2016 07:51:14 -0700
Message-ID: <57DEA9E2.3000703@cumulusnetworks.com>
References: <1473958082-30982-1-git-send-email-pruddy@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, jiri@resnulli.us,
        alexander.h.duyck@intel.com, stephen@networkplumber.org,
        lboccass@brocade.com, sven@brocade.com
To: Patrick Ruddy <pruddy@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:35919 "EHLO
        mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754286AbcIROvQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 18 Sep 2016 10:51:16 -0400
Received: by mail-pa0-f53.google.com with SMTP id id6so40258186pad.3
        for <netdev@vger.kernel.org>; Sun, 18 Sep 2016 07:51:16 -0700 (PDT)
In-Reply-To: <1473958082-30982-1-git-send-email-pruddy@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/15/16, 9:48 AM, Patrick Ruddy wrote:
> Add RTM_NEWADDR and RTM_DELADDR netlink messages with family
> AF_UNSPEC to indicate interest in specific unicast and multicast
> hardware addresses. These messages are sent when addresses are
> added or deleted from the appropriate interface driver.
> Added AF_UNSPEC GETADDR function to allow the netlink notifications
> to be replayed to avoid loss of state due to application start
> ordering or restart.
>
> Signed-off-by: Patrick Ruddy <pruddy@brocade.com>
> ---

RTM_NEWADDR and RTM_DELADDR are not used to add these entries to the kernel.
so, it seems a bit wrong to use RTM_NEWADDR and RTM_DELADDR to notify them to
userspace and also to request a special dump of these addresses.

This could just be a new nested netlink attribute in the existing link dump ?
