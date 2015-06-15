From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [PATCH next v1] bonding: Display LACP info only to CAP_NET_ADMIN
 capable user
Date: Mon, 15 Jun 2015 10:08:13 -0400
Message-ID: <20150615140812.GE588@gospo.home.greyhouse.net>
References: <1434137087-10555-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@gmail.com>,
	Nikolay Aleksandrov <razor@blackwall.org>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Maciej Zenczykowski <maze@google.com>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f170.google.com ([209.85.220.170]:34559 "EHLO
	mail-qk0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754051AbbFOOII (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jun 2015 10:08:08 -0400
Received: by qkdm188 with SMTP id m188so32924819qkd.1
        for <netdev@vger.kernel.org>; Mon, 15 Jun 2015 07:08:07 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1434137087-10555-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 12, 2015 at 12:24:47PM -0700, Mahesh Bandewar wrote:
> Actor and Partner details can be accessed via proc-fs and sys-fs
> entries. These interfaces are world readable at this moment. The
> earlier patch-series made the LACP communication secure to avoid
> nuisance attack from within the same L2 domain but it did not
> prevent "someone unprivileged" looking at that information on host
> and perform the same act.
> 
> This patch essentially avoids spitting those entries if the user
> in question does not have enough privileges.

Mahesh,

Nik just posted patches to add the ability to add actor_oper_port_state
and partner_oper.port_state to netlink and sysfs.  Since you are
restricting the display of those values in /proc and /sys to only those
users with CAP_NET_ADMIN set, there is some overlap that needs to be
resolved.

More importantly Nik's set reminds me that the netlink case for this
restriction also needs to be handled or the functionality desired is
effectively not implemented since a user could query these values via
netlink.

Since Nik's patch is smaller and it should be easy to for you rebase on
top of it, I'm going to ack his and once you pull in his changes and add
netlink support I think your patch should be fine -- as long as there
are no major objections to having a different netlink message returned
based on the netlink user.

-andy
