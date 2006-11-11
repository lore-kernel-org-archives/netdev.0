From: Joshua Brindle <jbrindle@tresys.com>
Subject: Re: [PATCH 0/3] labeled-ipsec: Repost patchset with updates [Originally:
 mlsxfrm: Various Fixes]
Date: Sat, 11 Nov 2006 11:22:19 -0500
Message-ID: <4555F8BB.30105@tresys.com>
References: <45526241.10805@trustedcs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov, jmorris@namei.org,
	sds@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from tresys.irides.com ([216.250.243.126]:19548 "HELO
	exchange.columbia.tresys.com") by vger.kernel.org with SMTP
	id S1424412AbWKKQWc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 11 Nov 2006 11:22:32 -0500
To: Venkat Yekkirala <vyekkirala@TrustedCS.com>
In-Reply-To: <45526241.10805@trustedcs.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Venkat Yekkirala wrote:
> This patchset is against davem's net-2.6.git. Please apply to 2.6.19.
>
> The following are the changes since the previous post of this patchset:
>
> 1. Separate BUG_ON usage per Eric's suggestion.
>
> 2. Replace security_sid_compare with a simple sid compare check per
>    a suggestion from Paul/Stephen.
>   
I pulled in the lspp respin kernels and am checking the labeling 
behavior now so I should have a full response later, however I ran into 
one unexpected thing immediately on bootup with the new kernel:

audit(1163061323.188:197): avc:  denied  { send } for  pid=1676 
comm="modprobe" daddr=ff02:0000:0000:0000:0000:0000:0000:0016 netif=eth0 
scontext=system_u:system_r:kernel_t:s0 
tcontext=system_u:object_r:unlabeled_t:s0 tclass=packet
audit(1163061343.335:204): avc:  denied  { send } for  pid=1804 
comm="avahi-daemon" saddr=fe80:0000:0000:0000:020c:29ff:fe72:2dd1 
src=5353 daddr=ff02:0000:0000:0000:0000:0000:0000:00fb dest=5353 
netif=eth0 scontext=system_u:system_r:avahi_t:s0 
tcontext=system_u:object_r:unlabeled_t:s0 tclass=packet
audit(1163061343.338:205): avc:  denied  { recv } for  pid=1804 
comm="avahi-daemon" saddr=fe80:0000:0000:0000:020c:29ff:fe72:2dd1 
src=5353 daddr=ff02:0000:0000:0000:0000:0000:0000:00fb dest=5353 
netif=eth0 scontext=system_u:system_r:avahi_t:s0 
tcontext=system_u:object_r:unlabeled_t:s0 tclass=packet
audit(1163061346.139:210): avc:  denied  { send } for  pid=1856 
comm="smartd-conf.py" saddr=fe80:0000:0000:0000:020c:29ff:fe72:2dd1 
daddr=ff02:0000:0000:0000:0000:0000:0000:0016 netif=eth0 
scontext=system_u:system_r:kernel_t:s0 
tcontext=system_u:object_r:unlabeled_t:s0 tclass=packet

These denials come after iptables-restore sets up labeling in the mangle 
table so I'm not sure why they are unlabeled.. They also don't say which 
port they were using, perhaps is it a different protocol that our packet 
labeling isn't covering yet? Is there any way we could get protocol 
information in the denial?

