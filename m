From: Peter Bieringer <pb@bieringer.de>
Subject: Re: [RFC IPv6] Disabling IPv6 autoconf
Date: Tue, 29 Aug 2006 13:31:27 +0200
Message-ID: <44F4258F.5070406@bieringer.de>
References: <20060829082435.GA2676@suse.de> <200608291421.18069.hasso@estpak.ee>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-relay.aerasec.de ([212.18.21.178]:20421 "EHLO
	smtp1.aerasec.de") by vger.kernel.org with ESMTP id S964898AbWH2Lbc
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Aug 2006 07:31:32 -0400
To: Hasso Tepper <hasso@estpak.ee>
In-Reply-To: <200608291421.18069.hasso@estpak.ee>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hasso Tepper schrieb:
> Olaf Kirch wrote:
>> When the Xen people looked for a way to disable IPv6 autoconf of the
>> bridge, they didn't find any way to do it without bringing up the
>> device first (and thereby triggering DAD).
> 
> Because no /proc/sys/net/ipv6/conf/<interface> exist (yes, I know it's 
> user visible effect)? This is just odd IMHO. I asked why it was changed 
> and how userspace should behave now regarding this, but got no answer.
> 
> Simple scenario with GNU/Debian:
> 
> Computer is booted with no ethernet link. Ethernet interface should get 
> address via autoconf. No link => no IPv6 addresses on interface => 
> no /proc/sys/net/ipv6/conf/<interface>. Bootup scripts (procps.sh reading 
> sysctl.conf existing in most of distributions AFAIK) can't set/get 
> anything in /proc/sys/net/ipv6/conf/<interface> because it doesn't exist.
> 
> How userspace should behave now? Mandating daemon which listens interface 
> events via netlink?

BTW: this is also the reason why autoconf or accept_ra cannot be
disabled by e.g. initscripts *per* interface before bringing one up.

This issue was discussed some time ago with Pekka and reported in
https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=169809

There is still no solution for that afaik.

	Peter
-- 
Dr. Peter Bieringer                     http://www.bieringer.de/pb/
GPG/PGP Key 0x958F422D                       mailto:pb@bieringer.de
Deep Space 6 Co-Founder and Core Member  http://www.deepspace6.net/
OpenBC                    http://www.openbc.com/hp/Peter_Bieringer/
Personal invitation to OpenBC  http://www.openbc.com/go/invita/3889
