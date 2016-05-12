From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 0/4] return offloaded stats as default and expose original sw start
Date: Thu, 12 May 2016 13:48:46 +0200
Message-ID: <1463053730-14991-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, nogahf@mellanox.com, idosch@mellanox.com,
	eladr@mellanox.com, yotamg@mellanox.com, ogerlitz@mellanox.com,
	roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	linville@tuxdriver.com, tgraf@suug.ch, gospo@cumulusnetworks.com,
	sfeldma@gmail.com, sd@queasysnail.net, eranbe@mellanox.com,
	ast@plumgrid.com, edumazet@google.com, hannes@stressinduktion.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33529 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751425AbcELLsw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2016 07:48:52 -0400
Received: by mail-wm0-f68.google.com with SMTP id r12so15647868wme.0
        for <netdev@vger.kernel.org>; Thu, 12 May 2016 04:48:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Until now we had stats functions return SW statistics. However, it makes
a lot of sense to return HW stats as default. The existing apps count with
having the defaults stats complete, but that is not true now as the offloaded
forward traffic is not visible there.

If user wants to know real SW stats, this patchset provides way to get
it as well.

---
v1->v2:
- patch3/4: 
  - fixed NULL initialization

Nogah Frankel (4):
  netdevice: add SW statistics ndo
  rtnetlink: add HW/SW stats distinction in rtnl_fill_stats
  net: core: add SW stats to if_stats_msg
  mlxsw: spectrum: Implement SW stats ndo and expose HW stats by default

 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 65 ++++++++++++++++++++++----
 include/linux/netdevice.h                      | 12 +++++
 include/uapi/linux/if_link.h                   |  2 +
 net/core/dev.c                                 | 25 ++++++++++
 net/core/rtnetlink.c                           | 55 +++++++++++++++++++---
 5 files changed, 145 insertions(+), 14 deletions(-)

-- 
2.5.5
