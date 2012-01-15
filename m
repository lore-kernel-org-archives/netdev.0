From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Subject: Re: ipset 6.x - bitmap:ip,mac not working
Date: Sun, 15 Jan 2012 18:28:54 +0100 (CET)
Message-ID: <alpine.DEB.2.00.1201151827460.29134@blackhole.kfki.hu>
References: <4F13044A.7070900@ttx.sk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Vlado Drzik <vlado@ttx.sk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-in.kfki.hu ([148.6.0.26]:41245 "EHLO smtp1.kfki.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751575Ab2AOR24 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 15 Jan 2012 12:28:56 -0500
In-Reply-To: <4F13044A.7070900@ttx.sk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 15 Jan 2012, Vlado Drzik wrote:

> Would like to ask whether someone is actually using IP sets in recent
> kernel version with bitmap:ip,mac match.
> I've updated from ipsets 4.x to ipset 6.10 and kernel 3.1.8 and I've
> noticed that bitmap:ip,mac never match.
> I've tested also bitmap:ip and that one is working fine.
> 
> Test setup:
> 
> ipset create ipmac_test bitmap:ip,mac range 172.16.0.0/16
> ipset add ipmac_test 172.16.1.254,00:11:22:33:44:55
> 
> iptables -I INPUT -i eth0 -m set --match-set ipmac_test src

That's a wrong rule: bitmap:ip,mac is a two dimensional set and therefore 
it requires two directional parameters:

iptables -I INPUT -i eth0 -m set --match-set ipmac_test src,src

Best regards,
Jozsef
-
E-mail  : kadlec@blackhole.kfki.hu, kadlecsik.jozsef@wigner.mta.hu
PGP key : http://www.kfki.hu/~kadlec/pgp_public_key.txt
Address : Wigner Research Centre for Physics, Hungarian Academy of Sciences
          H-1525 Budapest 114, POB. 49, Hungary
