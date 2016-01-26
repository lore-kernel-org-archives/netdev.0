From: Flavio Leitner <fbl@sysclose.org>
Subject: Cannot set ageing to zero
Date: Tue, 26 Jan 2016 15:26:30 -0200
Message-ID: <20160126152630.422f5ac4@x240.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>
To: netdev <netdev@vger.kernel.org>, Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sender163-mail.zoho.com ([74.201.84.163]:25349 "EHLO
	sender163-mail.zoho.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966811AbcAZR0I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jan 2016 12:26:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi,

After the commit[1] below, we can't set ageing on a Linux bridge device
to zero.  It seems rocker needs the minimum value, but we can't break
an old and valid Linux bridge behavior. 

[1] commit c62987bbd8a1a1664f99e89e3959339350a6131e
Author: Scott Feldman <sfeldma@gmail.com>
Date:   Thu Oct 8 19:23:19 2015 -0700

    bridge: push bridge setting ageing_time down to switchdev
    
    Use SWITCHDEV_F_SKIP_EOPNOTSUPP to skip over ports in bridge that
    don't support setting ageing_time (or setting bridge attrs in
    general). 
    If push fails, don't update ageing_time in bridge and return err to
    user. 
    If push succeeds, update ageing_time in bridge and run gc_timer now
    to recalabrate when to run gc_timer next, based on new ageing_time.
    
    Signed-off-by: Scott Feldman <sfeldma@gmail.com>
    Signed-off-by: Jiri Pirko <jiri@resnulli.us>
    Acked-by: Jiri Pirko <jiri@mellanox.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>


-- 
fbl
