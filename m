From: Kazunori MIYAZAWA <kazunori@miyazawa.org>
Subject: Re: [PATCH][IPSEC][6/7] inter address family ipsec tunnel
Date: Fri, 01 Dec 2006 14:07:04 +0900
Message-ID: <456FB878.4080109@miyazawa.org>
References: <20061124143901.0db589b8.kazunori@miyazawa.org> <20061130.170503.35356518.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: miika@iki.fi, Diego.Beltrami@hiit.fi, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from usagi004.linux-ipv6.org ([203.178.140.4]:9630 "EHLO
	miyazawa.org") by vger.kernel.org with ESMTP id S1758886AbWLAFHp
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Dec 2006 00:07:45 -0500
To: David Miller <davem@davemloft.net>
In-Reply-To: <20061130.170503.35356518.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Kazunori MIYAZAWA <kazunori@miyazawa.org>
> Date: Fri, 24 Nov 2006 14:39:01 +0900
> 
>> This patch fixes mtu calculation of IPv4
>>
>> ip_append_data should refer the mtu of "dst" not "path".
>> if "dst" is stacked, "path" is the actual dst_entry in
>> the routing table.
>> therefore the mtu of "path" equals link mtu which is
>> depends on the device so that it ignores the header length
>> and the trailer length
>> "dst" has mtu for creating packet.
>>
>> Signed-off-by: Miika Komu <miika@iki.fi>
>> Signed-off-by: Diego Beltrami <Diego.Beltrami@hiit.fi>
>> Signed-off-by: Kazunori Miyazawa <miyazawa@linux-ipv6.org>
> 
> I'm not sure about this change.
> 
> If you look at the code in this function, "mtu" is always used with
> adjustments via 'exthdrlen' (which is set to rt->u.dst.header_len).
> So it seems the encapsulation is taken into account.
> 

Oh, sorry. I misread the code.
I tested with IPv4 over IPv4 IPsec tunnel. The original code works.
Sorry this patch was wrong. Please throw away [6/7] and [7/7].

> Perhaps any problem you are seeing is some artifact of the ipv6 in
> ipv4 tunnel implementation.  Otherwise we'd have other reports of this
> problem, wouldn't we?

The easy test is that you create IPv6 over IPv6 IPsec tunnel between 2 
hosts, the tunnel is terminated by themselves, and send icmp echo
packets which are longer than the mtu such as 2000. Then it seems
that the kernel  returns too big messages to ping6.
I guess mtu calculation and/or building packets of IPv6 has some problem

If you use another host (SGW) to encapsulate the packets,
I think it succeeds because SGW returns a too big message and the
packet sending host learns and fragments properly.

I had same situation like IPv6 over IPv6 IPsec self tunneling
under IPv6 over IPv4 IPsec tunneling test.

I'm going to trace the problem.

Thank you.

--
Kazunori Miyazawa
