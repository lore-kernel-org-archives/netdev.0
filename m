From: Ivan Mitev <imitev@obs.bg>
Subject: Re: Slow OOM in netif_RX function
Date: Tue, 05 Feb 2008 11:04:15 +0200
Message-ID: <47A8268F.6020301@obs.bg>
References: <4798CAA9.1080005@obs.bg> <4798E32E.6080003@cosmosbay.com> <20080124211810.3E24A46E9A@smtp.obs.bg> <p73tzl282ij.fsf@bingen.suse.de> <20080125141204.GA25510@ghostprotocols.net> <47A315DC.3070101@obs.bg> <47A31BBA.8040307@cosmosbay.com> <47A33D02.8050503@obs.bg> <47A72740.9030706@obs.bg> <20080204155526.GA7988@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ivan Dichev <idichev@obs.bg>, Eric Dumazet <dada1@cosmosbay.com>,
	Arnaldo Carvalho de Melo <acme@redhat.com>,
	netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from obs.bg ([213.91.169.3]:37313 "EHLO smtp.obs.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752070AbYBEJcl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Feb 2008 04:32:41 -0500
In-Reply-To: <20080204155526.GA7988@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


[(the other) Ivan took a few days holidays, so I'm replacing him for 
this issue.]

Andi, you spotted it, it was really the start of an IP header, and it 
shows up that these are ESP packets for a quite complicated VPN tunnel 
we have (re-routing packets from an office to another, with some NAT on 
top of that). So openswan/ipsec.ko seems to be the problem here, I will 
file a bug report there. Meanwhile we'll try to set up manual keying and 
decrypt the encrypted payload to gather more details on the packets.

My apologies, the issue seems to be with an out-of-tree module, but we 
really didn't think the problem was there (there's no correlation 
between the leak increase and vpn/ike traffic). But it was interesting 
to understand slabs, learn how to setup/use crash, and analyze memory 
bits :)

Thanks again to all the people who helped !

Ivan Mitev


Andi Kleen wrote:
>> Nothing that looks like a struct net_device. All the dumped leaked slab
>> look the same until "45 20 05 d8" (the ascii 'E' on the 3rd line).
> 
> 45 ... is often the start of an IP header (IPv4, 5*4=20 bytes length)
> 
> You could dump them to a file (e.g. using a sial script) and then
> look at them with tcpdump or similar to get an idea what kinds 
> of packets they are.
> 
> -Andi
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

