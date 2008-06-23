From: "Julius Volz" <juliusv@google.com>
Subject: Re: [PATCH] IRDA: Fix genlmsg_put() return value check.
Date: Mon, 23 Jun 2008 22:29:05 +0200
Message-ID: <f4845fc0806231329p7ef94a8dqafe63feea89ad949@mail.gmail.com>
References: <1214248629-6208-1-git-send-email-juliusv@google.com>
	 <485FFCE3.2050800@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, samuel@sortiz.org, netdev@vger.kernel.org
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:59154 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751569AbYFWU3P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2008 16:29:15 -0400
Received: from zps76.corp.google.com (zps76.corp.google.com [172.25.146.76])
	by smtp-out.google.com with ESMTP id m5NKT735024310
	for <netdev@vger.kernel.org>; Mon, 23 Jun 2008 21:29:07 +0100
Received: from yx-out-1718.google.com (yxn6.prod.google.com [10.190.4.70])
	by zps76.corp.google.com with ESMTP id m5NKT6Vi005974
	for <netdev@vger.kernel.org>; Mon, 23 Jun 2008 13:29:06 -0700
Received: by yx-out-1718.google.com with SMTP id 6so355524yxn.56
        for <netdev@vger.kernel.org>; Mon, 23 Jun 2008 13:29:06 -0700 (PDT)
In-Reply-To: <485FFCE3.2050800@trash.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 23, 2008, Patrick McHardy wrote:
> Good catch, but the correct return value for insufficient
> space in the skb is -ENOSPC.

Hm, seems we have many inconsistent values returned in exactly this
situation (in response to genlmsg_put), but none of them are -ENOSPC:

fs/dlm/netlink.c: -EINVAL
net/netlink/genetlink.c: -1
net/netlabel/netlabel_unlabeled.c: -ENOMEM
net/netlabel/netlabel_cipso_v4.c: -ENOMEM
net/netlabel/netlabel_mgmt.c: -ENOMEM
net/wireless/nl80211.c: -1
drivers/acpi/event.c: -ENOMEM
kernel/taskstats.c: -EINVAL

Seems like -ENOMEM is most common, don't know if that means it's
correct, though...

I was also using -ENOMEM in my Netlink code, so better convert all my
new uses to -ENOSPC?

Julius

-- 
Google Switzerland GmbH
