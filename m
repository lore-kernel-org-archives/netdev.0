From: Roel Kluin <roel.kluin@gmail.com>
Subject: [TCP]: min_t/max_t confusion in tcp_select_initial_window()?
Date: Wed, 23 Dec 2009 03:00:24 +0100
Message-ID: <4B3179B8.5000403@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f219.google.com ([209.85.219.219]:34718 "EHLO
	mail-ew0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751804AbZLWB55 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Dec 2009 20:57:57 -0500
Received: by ewy19 with SMTP id 19so5905251ewy.21
        for <netdev@vger.kernel.org>; Tue, 22 Dec 2009 17:57:54 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I could be confused, but in net/ipv4/tcp_output.c:217:

                space = max_t(u32, sysctl_tcp_rmem[2], sysctl_rmem_max);
                space = min_t(u32, space, *window_clamp);
------------------------^^^^^

shouldn't the min_t and max_t be exchanged? i.e.

                space = min_t(u32, sysctl_tcp_rmem[2], sysctl_rmem_max);
                space = max_t(u32, space, *window_clamp);

Thanks, Roel
