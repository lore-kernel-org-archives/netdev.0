From: Kris Katterjohn <katterjohn@gmail.com>
Subject: Re: [PATCH] IPv4 raw_hdrincl_nomangle sysctl
Date: Wed, 17 Dec 2008 15:11:25 -0600
Message-ID: <49496AFD.4010407@gmail.com>
References: <494964CA.5050109@gmail.com> <20081217.124841.169000877.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmailhost06.isp.att.net ([207.115.11.56]:61467 "EHLO
	fmailhost06.isp.att.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751671AbYLQVVa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2008 16:21:30 -0500
In-Reply-To: <20081217.124841.169000877.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On 12/17/2008 02:48 PM, David Miller wrote:
> From: Kris Katterjohn <katterjohn@gmail.com>
> Date: Wed, 17 Dec 2008 14:44:58 -0600
> 
>> I've attached a patch to add a net.ipv4.raw_hdrincl_nomangle sysctl (defaults
>> to 0) to control whether or not Linux changes the header passed using
>> IP_HDRINCL (checksum, IPID, etc).  This way it's not required to build a
>> special kernel simply to have control over what you send.  This was needed,
>> for example, in this discussion[1] on Nmap's packet handling.
> 
> If you want full control, use AF_PACKET to send your frames.
> 
> Yes, this means you'll need to choose the outgoing device and compose
> the link level header, but that's the price for control.
> 
> Using IPV4 RAW sockets implies you want some help from that
> part of the stack, if you don't then simply use direct pure
> packet sends via AF_PACKET.

Indeed I guess I will just use PF_PACKET from now on.  It's just that the
convenience of SOCK_RAW/IP_HDRINCL compared to doing the same thing with
AF_PACKET makes it a good choice for this in my mind, as long as the default
behavior is to still make the modifications as it is now.

Of course I still think 'sysctl net.ipv4.raw_hdrincl_nomangle=1' is price
enough for control :)

Thanks for the very speedy response,
Kris Katterjohn

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iQIcBAEBAgAGBQJJSWrcAAoJEP9K37xXYl36BYQQAJXkze06P4Q01co2ouXo2NW1
kW62Mnlvul34+y6y7vQCyIY51NLhjSSSbHnYnTqkwDOek3ai+7oux7H8B0o6QG7X
2Uf+aJVRjHGKsQrr3fPweXkvrCllkRVjht0SXNmPvRk7ey9Gobe59BPbfmLOTyp3
8P7G8hyT71hdfvUrWBLwXO9OgPntUVhZYKJdkPwVFjsrzOlCeTIB1SA/GdsMQFEr
ZzO7YN0MsGl3CmcxQtDqtvkhJeBoy93fC+KE4n+h0G8lGaXkEVBtTXvIPxV4CgTV
tCaZtDPkxePcT5oCFnzvht3BZ0UG18kodn6nPItbW2rX6jO77rOMJj+8ZNu9n8KC
UC4Bda3i7XBWfltp6NK6FsdNz3VFeIRNc5nw50lYci0IAUGGZSzNvCs6STGKYzeb
gWQwwRxqR0hUCZrZ10/mFqNV4BwgzBLA7TvPVRTql3stXNs1hl4syMJzCxjETOou
28iOEGGQCN4nihkr6qKUPKuf9zpg3MlKJnGkMFuJFz16K8pAadeNRtQolwfqOdyT
EKkG50MrQVEtAFNo4cLyW7lCSXrYdqV8AY1tQkfkqOeeuAz/CEW99o2YbsPzIpNb
CNUzjXbxjc2XJZs+aoDhY5uox64ORbxhXv9pdqjI4i1YQcF/tFlmFIN5Y2+0/Y6A
u8RNb4ayD1J4qQ2ZtWFn
=n6Mg
-----END PGP SIGNATURE-----
