From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH net-next 2/2] devlink: fix trace format string
Date: Wed, 13 Jul 2016 23:03:38 +0200
Message-ID: <20160713210338.1647521-2-arnd@arndb.de>
References: <20160713210338.1647521-1-arnd@arndb.de>
Cc: netdev@vger.kernel.org, Steven Rostedt <rostedt@goodmis.org>,
	Ingo Molnar <mingo@redhat.com>,
	"David S . Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>
To: Jiri Pirko <jiri@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([217.72.192.74]:55157 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751159AbcGMVET (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jul 2016 17:04:19 -0400
In-Reply-To: <20160713210338.1647521-1-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Including devlink.h on ARM and probably other 32-bit architectures results in
a harmless warning:

In file included from ../include/trace/define_trace.h:95:0,
                 from ../include/trace/events/devlink.h:51,
                 from ../net/core/devlink.c:30:
include/trace/events/devlink.h: In function 'trace_raw_output_devlink_hwmsg':
include/trace/events/devlink.h:42:12: error: format '%lu' expects argument of type 'long unsigned int', but argument 10 has type 'size_t {aka unsigned int}' [-Werror=format=]

The correct format string for 'size_t' is %zu, not %lu, this works on all
architectures.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: e5224f0fe2ac ("devlink: add hardware messages tracing facility")
---
 include/trace/events/devlink.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/trace/events/devlink.h b/include/trace/events/devlink.h
index 26f92d3c7e9c..4b75a6f986fc 100644
--- a/include/trace/events/devlink.h
+++ b/include/trace/events/devlink.h
@@ -47,7 +47,7 @@ TRACE_EVENT(devlink_hwmsg,
 		__entry->len = len;
 	),
 
-	TP_printk("bus_name=%s dev_name=%s owner_name=%s incoming=%d type=%lu buf=0x[%*phD] len=%lu",
+	TP_printk("bus_name=%s dev_name=%s owner_name=%s incoming=%d type=%lu buf=0x[%*phD] len=%zu",
 		  __get_str(bus_name), __get_str(dev_name),
 		  __get_str(owner_name), __entry->incoming, __entry->type,
 		  (int) __entry->len, __get_dynamic_array(buf), __entry->len)
-- 
2.9.0
