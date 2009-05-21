From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: ipt_MASQUERADE weirdness (consuming CPU cycles while not used)
Date: Thu, 21 May 2009 20:00:52 +0200
Message-ID: <4A1596D4.6000708@netfilter.org>
References: <200905182219.30216.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Denys Fedoryschenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:60840 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751587AbZEUSfB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 May 2009 14:35:01 -0400
In-Reply-To: <200905182219.30216.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denys Fedoryschenko wrote:
> I have loaded pppoe (1700 users). I test one rule for short time with -j 
> MASQUERADE, then removed it and reset conntrack (conntrack -F). But still i 
> can see it is consuming CPU even when it is not used in any rule. Even i 
> reboot server and just load rules that dont have MASQUERADE, and just load 
> module - it will start consuming CPU immediately.

Are you using 2.6.29 with any conntrack helper loaded? In that case this
fix is not in -stable yet.

http://kerneltrap.org/mailarchive/linux-netdev/2009/4/8/5440564

> 64811     3.7735  ipt_MASQUERADE           ipt_MASQUERADE           device_cmp

device_cmp() by nf_ct_iterate_cleanup() when NETDEV_DOWN event is
received. Weird, is your device going down quite often? Another
possibility is that there's some entry stuck in the conntrack table that
we cannot delete, perhaps we're leaking refcounts somewhere.

-- 
"Los honestos son inadaptados sociales" -- Les Luthiers
