From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v3 0/4] return offloaded stats as default and expose original sw start
Date: Fri, 13 May 2016 16:54:13 +0200
Message-ID: <1463151257-3972-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, nogahf@mellanox.com, idosch@mellanox.com,
	eladr@mellanox.com, yotamg@mellanox.com, ogerlitz@mellanox.com,
	roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	linville@tuxdriver.com, tgraf@suug.ch, gospo@cumulusnetworks.com,
	sfeldma@gmail.com, sd@queasysnail.net, eranbe@mellanox.com,
	ast@plumgrid.com, edumazet@google.com, hannes@stressinduktion.org,
	f.fainelli@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:34282 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751531AbcEMOyU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2016 10:54:20 -0400
Received: by mail-wm0-f67.google.com with SMTP id n129so4202649wmn.1
        for <netdev@vger.kernel.org>; Fri, 13 May 2016 07:54:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

From: Jiri Pirko <jiri@mellanox.com>

Until now we had stats functions return SW statistics. However, it makes
a lot of sense to return HW stats as default. The existing apps count with
having the defaults stats complete, but that is not true now as the offloaded
forward traffic is not visible there.

If user wants to know real SW stats, this patchset provides way to get
it as well.

---
v2->v3:
- patch1/4:
  - added dev_have_sw_stats helper
- patch2/4:
  - avoided memcpy as requerted by DaveM
- patch3/4:
  - use new dev_have_sw_stats helper
v1->v2:
- patch3/4: 
  - fixed NULL initialization

Nogah Frankel (4):
  netdevice: add SW statistics ndo
  rtnetlink: add HW/SW stats distinction in rtnl_fill_stats
  net: core: add SW stats to if_stats_msg
  mlxsw: spectrum: Implement SW stats ndo and expose HW stats by default

 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 65 ++++++++++++++++++++++----
 include/linux/netdevice.h                      | 13 ++++++
 include/uapi/linux/if_link.h                   |  2 +
 net/core/dev.c                                 | 31 ++++++++++++
 net/core/rtnetlink.c                           | 58 ++++++++++++++++++++---
 5 files changed, 155 insertions(+), 14 deletions(-)

-- 
2.5.5
