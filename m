From: "Venkat Yekkirala" <vyekkirala@trustedcs.com>
Subject: RE: [PATCH 0/3] labeled-ipsec: Repost patchset with updates [Originally: mlsxfrm: Various Fixes]
Date: Mon, 13 Nov 2006 09:42:38 -0600
Message-ID: <000401c7073a$5a762be0$cc0a010a@tcssec.com>
References: <4555F8BB.30105@tresys.com>
Reply-To: <vyekkirala@trustedcs.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <selinux@tycho.nsa.gov>,
	<jmorris@namei.org>, <sds@tycho.nsa.gov>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:18547 "EHLO
	tcsfw4.tcs-sec.com") by vger.kernel.org with ESMTP id S1755151AbWKMPnJ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Nov 2006 10:43:09 -0500
To: "'Joshua Brindle'" <jbrindle@tresys.com>
In-Reply-To: <4555F8BB.30105@tresys.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> I pulled in the lspp respin kernels and am checking the labeling 
> behavior now so I should have a full response later, however 
> I ran into 
> one unexpected thing immediately on bootup with the new kernel:

Just FYI- The labeled-ipsec patch doesn't affect or influence the
packet class handling in any manner.

> 
> audit(1163061323.188:197): avc:  denied  { send } for  pid=1676 
> comm="modprobe" daddr=ff02:0000:0000:0000:0000:0000:0000:0016 
> netif=eth0 
> scontext=system_u:system_r:kernel_t:s0 
> tcontext=system_u:object_r:unlabeled_t:s0 tclass=packet
> audit(1163061343.335:204): avc:  denied  { send } for  pid=1804 
> comm="avahi-daemon" saddr=fe80:0000:0000:0000:020c:29ff:fe72:2dd1 
> src=5353 daddr=ff02:0000:0000:0000:0000:0000:0000:00fb dest=5353 
> netif=eth0 scontext=system_u:system_r:avahi_t:s0 
> tcontext=system_u:object_r:unlabeled_t:s0 tclass=packet
> audit(1163061343.338:205): avc:  denied  { recv } for  pid=1804 
> comm="avahi-daemon" saddr=fe80:0000:0000:0000:020c:29ff:fe72:2dd1 
> src=5353 daddr=ff02:0000:0000:0000:0000:0000:0000:00fb dest=5353 
> netif=eth0 scontext=system_u:system_r:avahi_t:s0 
> tcontext=system_u:object_r:unlabeled_t:s0 tclass=packet
> audit(1163061346.139:210): avc:  denied  { send } for  pid=1856 
> comm="smartd-conf.py" saddr=fe80:0000:0000:0000:020c:29ff:fe72:2dd1 
> daddr=ff02:0000:0000:0000:0000:0000:0000:0016 netif=eth0 
> scontext=system_u:system_r:kernel_t:s0 
> tcontext=system_u:object_r:unlabeled_t:s0 tclass=packet
> 
> These denials come after iptables-restore sets up labeling in 
> the mangle 
> table so I'm not sure why they are unlabeled..

Could you list the mangle table rules and see that the above IPv6
addresses are covered (i.e. labeled appropriately) or otherwise that
your policy allows kernel_t to receive all packets (may or may not be
desired/good, just thinking out loud).

> They also 
> don't say which 
> port they were using,

The port info is currently available only for tcp/udp packets.

> perhaps is it a different protocol that 
> our packet 
> labeling isn't covering yet?

James can perhaps comment on this better, but it *should* be covered
to the extent that you are able to define mangle table/secmark rules
for them.

> Is there any way we could get protocol 
> information in the denial?

This is possible with kernel changes, specifically by adding protocol
to avc_audit_data. If Stephen agrees I can look into doing it.
