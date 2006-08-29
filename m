From: Hasso Tepper <hasso@estpak.ee>
Subject: Re: [RFC IPv6] Disabling IPv6 autoconf
Date: Tue, 29 Aug 2006 14:21:17 +0300
Message-ID: <200608291421.18069.hasso@estpak.ee>
References: <20060829082435.GA2676@suse.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from test.estpak.ee ([194.126.115.47]:43204 "EHLO devy.estpak.ee")
	by vger.kernel.org with ESMTP id S964897AbWH2LVg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2006 07:21:36 -0400
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by devy.estpak.ee (Postfix) with ESMTP id 9936E35E8E
	for <netdev@vger.kernel.org>; Tue, 29 Aug 2006 14:21:19 +0300 (EEST)
To: netdev@vger.kernel.org
In-Reply-To: <20060829082435.GA2676@suse.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Olaf Kirch wrote:
> When the Xen people looked for a way to disable IPv6 autoconf of the
> bridge, they didn't find any way to do it without bringing up the
> device first (and thereby triggering DAD).

Because no /proc/sys/net/ipv6/conf/<interface> exist (yes, I know it's 
user visible effect)? This is just odd IMHO. I asked why it was changed 
and how userspace should behave now regarding this, but got no answer.

Simple scenario with GNU/Debian:

Computer is booted with no ethernet link. Ethernet interface should get 
address via autoconf. No link => no IPv6 addresses on interface => 
no /proc/sys/net/ipv6/conf/<interface>. Bootup scripts (procps.sh reading 
sysctl.conf existing in most of distributions AFAIK) can't set/get 
anything in /proc/sys/net/ipv6/conf/<interface> because it doesn't exist.

How userspace should behave now? Mandating daemon which listens interface 
events via netlink?


regards,

-- 
Hasso Tepper
