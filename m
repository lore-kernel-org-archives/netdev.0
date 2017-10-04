From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 5/7] net: bonding: Add extack messages for some
 enslave failures
Date: Wed, 4 Oct 2017 08:38:28 +0200
Message-ID: <20171004063828.GB1895@nanopsycho>
References: <1507093134-20406-1-git-send-email-dsahern@gmail.com>
 <1507093134-20406-6-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, j.vosburgh@gmail.com, vfalico@gmail.com,
        andy@greyhouse.net, jiri@mellanox.com, idosch@mellanox.com,
        davem@davemloft.net, bridge@lists.linux-foundation.org
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:36507 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750797AbdJDGi3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2017 02:38:29 -0400
Received: by mail-wr0-f195.google.com with SMTP id k10so7399641wrk.3
        for <netdev@vger.kernel.org>; Tue, 03 Oct 2017 23:38:29 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1507093134-20406-6-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Oct 04, 2017 at 06:58:52AM CEST, dsahern@gmail.com wrote:
>A number of bond_enslave errors are logged using the netdev_err API.
>Return those messages to userspace via the extack facility.
>
>Signed-off-by: David Ahern <dsahern@gmail.com>
>---
> drivers/net/bonding/bond_main.c | 12 ++++++++++++
> 1 file changed, 12 insertions(+)
>
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index bc92307c2082..6688dc9154e0 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -1348,12 +1348,15 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev,
> 
> 	/* already in-use? */
> 	if (netdev_is_rx_handler_busy(slave_dev)) {
>+		NL_SET_ERR_MSG(extack,
>+			       "Device is in use and cannot be enslaved");

Please don't do this kind of wrapping. Just let the string be on the
same line.
