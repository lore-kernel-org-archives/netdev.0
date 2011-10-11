From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH] netconsole: enable netconsole can make net_device refcnt
 incorrent
Date: Tue, 11 Oct 2011 14:29:12 +0800
Message-ID: <4E93E238.7000105@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, eric.dumazet@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:58301 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750737Ab1JKG2m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Oct 2011 02:28:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  There is no check if netconsole is enabled current.
so when exec echo 1 > enabled;
the reference of net_device will increment always.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
  drivers/net/netconsole.c |    2 ++
  1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/netconsole.c b/drivers/net/netconsole.c
index ed2a397..4e6323d 100644
--- a/drivers/net/netconsole.c
+++ b/drivers/net/netconsole.c
@@ -307,6 +307,8 @@ static ssize_t store_enabled(struct 
netconsole_target *nt,
                 return err;
         if (enabled < 0 || enabled > 1)
                 return -EINVAL;
+       if (enabled == nt->enabled)
+               return err;

         if (enabled) {  /* 1 */

-- 
1.7.1
