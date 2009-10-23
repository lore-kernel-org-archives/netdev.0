From: Jasper Spaans <spaans@fox-it.com>
Subject: Re: bridging + load balancing bonding
Date: Fri, 23 Oct 2009 10:38:51 +0200
Message-ID: <20091023083851.GA18457@spaans.fox.local>
References: <20091022122339.GA20148@spaans.fox.local> <4AE07D3C.3040702@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.fox-it.com ([82.94.91.210]:26909 "EHLO mail2.fox-it.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751168AbZJWIiw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Oct 2009 04:38:52 -0400
Content-Disposition: inline
In-Reply-To: <4AE07D3C.3040702@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

On Thu, Oct 22, 2009 at 05:41:48PM +0200, Eric Dumazet wrote:

> Very nice setup, and nice finding.
> 
> Dont locally generated (or outed) packets have h_source set to bond_dev->dev_addr anyway ?
> 
> So your solution might be the right fix...
> 
> About other ideas... I was thinking of TEE target (not in mainline unfortunatly) :
> 
> iptables -t mangle -A PREROUTING -i eth0 <some hash on mac addr>  -j TEE --gateway 192.168.99.1  # IDS1
> iptables -t mangle -A PREROUTING -i eth0 !<some hash on mac addr>  -j TEE --gateway 192.168.99.2  # IDS2

Unfortunately, this won't work: the TEE target works at IP-level, and
changes mac-addresses, which is a no-go thing for us.. (and we won't be able
to see non-IP traffic such as ARP on the IDS machines)

Jasper
-- 
Fox-IT Experts in IT Security!
T: +31 (0) 15 284 79 99
KvK Haaglanden 27301624
