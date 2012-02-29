From: WeipingPan <panweiping3@gmail.com>
Subject: Re: [PATCH][RFC] bonding: delete migrated IP addresses from the rlb
 hash table
Date: Wed, 29 Feb 2012 21:58:53 +0800
Message-ID: <4F4E2F1D.2080302@gmail.com>
References: <20120227173400.GB816@midget.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org
To: Jiri Bohac <jbohac@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:60406 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030661Ab2B2Ny1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Feb 2012 08:54:27 -0500
Received: by dajr28 with SMTP id r28so359971daj.19
        for <netdev@vger.kernel.org>; Wed, 29 Feb 2012 05:54:27 -0800 (PST)
In-Reply-To: <20120227173400.GB816@midget.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/28/2012 01:34 AM, Jiri Bohac wrote:
> Bonding in balance-alb mode records information from ARP packets
> passing through the bond in a hash table (rx_hashtbl).
>
> At certain situations (e.g. link change of a slave),
> rlb_update_rx_clients() will send out ARP packets to update ARP
> caches of other hosts on the network to achieve RX load balancing.
>
> The problem is that once an IP address is recorded in the hash
> table, it stays there indefinitely [1]. If this IP address is
> migrated to a different host in the network, bonding still sends
> out ARP packets that poison other systems' ARP caches with
> invalid information.
I met this problem, too.

> This patch solves this by looking at all incoming ARP packets,
> and checking if the source IP address is one of the source
> addresses stored in the rx_hashtbl. If it is, the corresponding
> hash table entries are removed. Thus, when an IP address is
> migrated, the first ARP broadcast by its new owner will purge the
> offending entries of rx_hashtbl.
>
>    (a simpler approach, where bonding would monitor IP address
>     changes on the local system does not work for setups like:
>     HostA --- NetworkA --- eth0-bond0-br0 --- NetworkB --- hostB
>     and an IP address migrating from HostB to HostA)
Could you explain in detail or step by step how to reproduce your problem ?
I made a patch but I do not know whether it can fix your problem.

thanks
Weiping Pan
