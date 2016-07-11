From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 1/2] devlink: add hardware messages tracing
 facility
Date: Mon, 11 Jul 2016 17:04:38 +0200
Message-ID: <20160711150438.GB3118@nanopsycho.orion>
References: <1468243128-6669-1-git-send-email-jiri@resnulli.us>
 <74df1f22-1777-fa69-1a82-cb26388060b8@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, idosch@mellanox.com,
	yotamg@mellanox.com, eladr@mellanox.com, nogahf@mellanox.com,
	ogerlitz@mellanox.com, ivecera@redhat.com, rostedt@goodmis.org,
	mingo@redhat.com, jolsa@kernel.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:36663 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030495AbcGKPEl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2016 11:04:41 -0400
Received: by mail-wm0-f68.google.com with SMTP id x83so14887222wma.3
        for <netdev@vger.kernel.org>; Mon, 11 Jul 2016 08:04:41 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <74df1f22-1777-fa69-1a82-cb26388060b8@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Jul 11, 2016 at 05:01:46PM CEST, dsa@cumulusnetworks.com wrote:
>On 7/11/16 7:18 AM, Jiri Pirko wrote:
>
>>diff --git a/net/core/devlink.c b/net/core/devlink.c
>>index b2e592a..8cfa3b0 100644
>>--- a/net/core/devlink.c
>>+++ b/net/core/devlink.c
>>@@ -26,6 +26,8 @@
>> #include <net/net_namespace.h>
>> #include <net/sock.h>
>> #include <net/devlink.h>
>>+#define CREATE_TRACE_POINTS
>>+#include <trace/events/devlink.h>
>
>EXPORT_TRACEPOINT_SYMBOL_GPL(trace_devlink_hwmsg);
>
>>
>> static LIST_HEAD(devlink_list);
>>
>>@@ -1679,6 +1681,13 @@ void devlink_free(struct devlink *devlink)
>> }
>> EXPORT_SYMBOL_GPL(devlink_free);
>>
>>+void devlink_trace_hwmsg(const struct devlink *devlink, bool incoming,
>>+			 unsigned long type, const u8 *buf, size_t len)
>>+{
>>+	trace_devlink_hwmsg(devlink, incoming, type, buf, len);
>>+}
>>+EXPORT_SYMBOL_GPL(devlink_trace_hwmsg);
>
>Then you don't need this devlink function.

I'm aware. I wanted to have this wrapper to have "devlink_" prefix.
Also, id devlink is not compiled in, this function is a noop.
