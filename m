From: "Joshua Brindle" <jbrindle@tresys.com>
Subject: RE: [PATCH 0/3] labeled-ipsec: Repost patchset with updates [Originally: mlsxfrm: Various Fixes]
Date: Mon, 13 Nov 2006 12:45:54 -0500
Message-ID: <6FE441CD9F0C0C479F2D88F959B015885C777B@exchange.columbia.tresys.com>
References: <000401c7073a$5a762be0$cc0a010a@tcssec.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <selinux@tycho.nsa.gov>,
	<jmorris@namei.org>, <sds@tycho.nsa.gov>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tresys.irides.com ([216.250.243.126]:58856 "HELO
	exchange.columbia.tresys.com") by vger.kernel.org with SMTP
	id S932126AbWKMRpz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Nov 2006 12:45:55 -0500
Content-class: urn:content-classes:message
In-Reply-To: <000401c7073a$5a762be0$cc0a010a@tcssec.com>
To: <vyekkirala@trustedcs.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> From: Venkat Yekkirala [mailto:vyekkirala@trustedcs.com] 
> 
> > I pulled in the lspp respin kernels and am checking the labeling 
> > behavior now so I should have a full response later, however I ran 
> > into one unexpected thing immediately on bootup with the new kernel:
> 
> Just FYI- The labeled-ipsec patch doesn't affect or influence 
> the packet class handling in any manner.
> 
> > 
> > audit(1163061323.188:197): avc:  denied  { send } for  pid=1676 
> > comm="modprobe" daddr=ff02:0000:0000:0000:0000:0000:0000:0016
> > netif=eth0
> > scontext=system_u:system_r:kernel_t:s0
> > tcontext=system_u:object_r:unlabeled_t:s0 tclass=packet
> > audit(1163061343.335:204): avc:  denied  { send } for  pid=1804 
> > comm="avahi-daemon" saddr=fe80:0000:0000:0000:020c:29ff:fe72:2dd1
> > src=5353 daddr=ff02:0000:0000:0000:0000:0000:0000:00fb dest=5353 
> > netif=eth0 scontext=system_u:system_r:avahi_t:s0
> > tcontext=system_u:object_r:unlabeled_t:s0 tclass=packet
> > audit(1163061343.338:205): avc:  denied  { recv } for  pid=1804 
> > comm="avahi-daemon" saddr=fe80:0000:0000:0000:020c:29ff:fe72:2dd1
> > src=5353 daddr=ff02:0000:0000:0000:0000:0000:0000:00fb dest=5353 
> > netif=eth0 scontext=system_u:system_r:avahi_t:s0
> > tcontext=system_u:object_r:unlabeled_t:s0 tclass=packet
> > audit(1163061346.139:210): avc:  denied  { send } for  pid=1856 
> > comm="smartd-conf.py" saddr=fe80:0000:0000:0000:020c:29ff:fe72:2dd1
> > daddr=ff02:0000:0000:0000:0000:0000:0000:0016 netif=eth0 
> > scontext=system_u:system_r:kernel_t:s0
> > tcontext=system_u:object_r:unlabeled_t:s0 tclass=packet
> > 
> > These denials come after iptables-restore sets up labeling in the 
> > mangle table so I'm not sure why they are unlabeled..
> 
> Could you list the mangle table rules and see that the above 
> IPv6 addresses are covered (i.e. labeled appropriately) or 
> otherwise that your policy allows kernel_t to receive all 
> packets (may or may not be desired/good, just thinking out loud).
> 

Oops, I don't have ipv6 rules (refpolicy doesn't generate them). I'm not
even sure why it was on since I don't use ipv6 at all.. 
