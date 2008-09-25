From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: support force_igmp_version=3 and force_mld_version=2 ?
Date: Thu, 25 Sep 2008 12:18:02 +0300 (EEST)
Message-ID: <alpine.LRH.2.00.0809251206180.26899@netcore.fi>
References: <OF447111C0.BCE492D0-ON882574CF.00250EFC-882574CF.00276685@us.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from netcore.fi ([193.94.160.1]:51420 "EHLO netcore.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752034AbYIYJdP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Sep 2008 05:33:15 -0400
In-Reply-To: <OF447111C0.BCE492D0-ON882574CF.00250EFC-882574CF.00276685@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 25 Sep 2008, David Stevens wrote:
>> 2) only force_igmp_version=[12] is supported.  It might be useful to
>>     support "force_igmp_version=3" as well, where the system will not
>>     fall back to IGMPv1 or IGMPv2 compat mode even if it thinks it sees
>>     or has seen an IGMPv1/v2 query.
...
>        Logging an error, as suggested in RFC 4604, is ok, but it
> really is only a performance issue. Without the filter information,
> the group memberships may be bigger than they need to be, but
> the filters will still be applied on the receiver. Ignoring queries
> or answering them with v3 are both broken, at least for the v2
> querier.

Note that it's not just a performance issue if the host would want to 
report an (S,G) for an SSM group.  This requires IGMPv3/MLDv2.  Then 
if it falls back to IGMPv2, it can only report (*,G), and it can no 
longer get the SSM transmission.  If a malicious host would send an 
IGMPv2 query on an otherwise IGMPv3-capable network segment, that 
packet would be a trivial DoS.

What I'm saying is that the compatibility mode is required in a 
scenario where you don't know which IGMP versions the legitimate nodes 
in the LAN support, but it also a DoS vector.  But in a managed 
network where you know the IGMP versions supported, forcing it may 
make sense.  This is why when you use sysctl toggles to change default 
behaviour, you're supposed to know what you're doing.

>        So, I don't think forcing IGMPv3 makes much sense. If you
> really cared about it, you could always add an iptables entry to
> drop them, right?

It's a bit tricky to figure out the correct rules to use if you want 
to drop all IGMPv1 and IGMPv2 traffic.

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
