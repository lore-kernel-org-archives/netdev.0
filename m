From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v2 1/4] net: switchdev: Prepare for deferred
 functions modifying objects
Date: Tue, 10 Jan 2017 11:09:01 +0100
Message-ID: <20170110100901.GB1827@nanopsycho>
References: <20170109204523.5843-1-f.fainelli@gmail.com>
 <20170109204523.5843-2-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        vivien.didelot@savoirfairelinux.com, andrew@lunn.ch,
        marcelo.leitner@gmail.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:34708 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934378AbdAJKJE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 05:09:04 -0500
Received: by mail-wm0-f66.google.com with SMTP id c85so28294227wmi.1
        for <netdev@vger.kernel.org>; Tue, 10 Jan 2017 02:09:04 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20170109204523.5843-2-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Jan 09, 2017 at 09:45:20PM CET, f.fainelli@gmail.com wrote:
>In preparation for adding support for deferred dump operations, allow
>specifying a deferred function whose signature allows read/write
>objects.
>
>Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
>---
> net/switchdev/switchdev.c | 21 ++++++++++++++++-----
> 1 file changed, 16 insertions(+), 5 deletions(-)
>
>diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
>index 017801f9dbaa..3d70ad02c617 100644
>--- a/net/switchdev/switchdev.c
>+++ b/net/switchdev/switchdev.c
>@@ -100,11 +100,14 @@ static DEFINE_SPINLOCK(deferred_lock);
> 
> typedef void switchdev_deferred_func_t(struct net_device *dev,
> 				       const void *data);
>+typedef void switchdev_deferred_func_rw_t(struct net_device *dev,
>+					  void *data);
> 
> struct switchdev_deferred_item {
> 	struct list_head list;
> 	struct net_device *dev;
> 	switchdev_deferred_func_t *func;
>+	switchdev_deferred_func_rw_t *func_rw;

I'm missing why you need to have 2 funcs here. Why you just can't re-use
func?


> 	unsigned long data[0];
> };
