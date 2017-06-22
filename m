From: Gal Pressman <galp@mellanox.com>
Subject: Re: [RFC PATCH net-next 0/3] ethtool: Add link down reason reporting
Date: Thu, 22 Jun 2017 14:37:26 +0300
Message-ID: <daf82b38-3642-6f4a-d9c0-c4cf806d6b7f@mellanox.com>
References: <1498050286-17141-1-git-send-email-galp@mellanox.com>
 <20170621211443.674e18a6@cakuba.netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        "John W. Linville" <linville@tuxdriver.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Vidya Sagar Ravipati <vidya@cumulusnetworks.com>,
        Jiri Pirko <jiri@mellanox.com>,
        David Decotigny <decot@googlers.com>, kernel-team@fb.com
To: Jakub Kicinski <kubakici@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr10078.outbound.protection.outlook.com ([40.107.1.78]:53109
        "EHLO EUR02-HE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750852AbdFVLhh (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 22 Jun 2017 07:37:37 -0400
In-Reply-To: <20170621211443.674e18a6@cakuba.netronome.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> Any particular reason for implementing this ABI in ethtool rather than
> via some netlink-based interface?  Devlink naturally comes to mind,
> given that cabling problems are not really related to the L2 and netdev
> shouldn't be required for diagnostics..

ethtool is already used for reporting and handling of link related stuff through get/set_link_ksettings.
How is reporting the link modes/port type/speed/etc different from this?
This feature is only an extension of the already existent "link detected" field.

Implementing this ABI in devlink is a good idea, but it shouldn't be instead of ethtool but in addition to ethtool.
Many users already use ethtool for this kind of info, we can tell them to use devlink to check why their link is down,
but I think it's nicer to have it all in one place.
