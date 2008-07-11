From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: Kernel panic 2.6.25.10 IXP4xx
Date: Fri, 11 Jul 2008 20:14:51 +0200
Message-ID: <m3skug1e5g.fsf@maximus.localdomain>
References: <m3y7481wbo.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: lkml <linux-kernel@vger.kernel.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:38398 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753131AbYGKSOx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Jul 2008 14:14:53 -0400
In-Reply-To: <m3y7481wbo.fsf@maximus.localdomain> (Krzysztof Halasa's message of "Fri\, 11 Jul 2008 13\:42\:19 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Krzysztof Halasa <khc@pm.waw.pl> writes:

> I'm told this is reproducible. The kernel in question is a (patched a
> bit) 2.6.25.10. ARM, Intel IXP425 CPU, big-endian. The exact
> patch set is available.

It seems the extra patches aren't really used, though. The
configuration is basically:

ifconfig eth0 192.168.0.1/24 (ixp4xx_eth driver, without the last fix
	correcting the device eth_poll() (NAPI) return value applied)

modprobe speedtch (USB ADSL, PPP over ATM)

iptables -t nat -A POSTROUTING -s 192.168.0.0/24 -d 0/0 -o ppp0 -j
	MASQUERADE (seems unrelated)

/sbin/pppd call speedtch (plugin pppoatm.so)

I'm going to try to recreate it on my machine.
-- 
Krzysztof Halasa
