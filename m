From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH net-next] ipv6: log src and dst along with "udp checksum is 0"
Date: Tue, 25 Feb 2014 21:07:12 +0100
Message-ID: <87y50z9csv.fsf@nemi.mork.no>
References: <1393356845-15287-1-git-send-email-bjorn@mork.no>
	<1393357478.8716.35.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:44033 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752430AbaBYUHT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Feb 2014 15:07:19 -0500
In-Reply-To: <1393357478.8716.35.camel@joe-AO722> (Joe Perches's message of
	"Tue, 25 Feb 2014 11:44:38 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joe Perches <joe@perches.com> writes:

> On Tue, 2014-02-25 at 20:34 +0100, Bj=C3=B8rn Mork wrote:
>> These info messages are rather pointless without any means to identi=
fy
>> the source of the bogus packets.  Logging the src and dst addresses
>> may help a bit.
> []
>> diff --git a/net/ipv6/ip6_checksum.c b/net/ipv6/ip6_checksum.c
> []
>> @@ -79,7 +79,8 @@ int udp6_csum_init(struct sk_buff *skb, struct udp=
hdr *uh, int proto)
>>  		/* RFC 2460 section 8.1 says that we SHOULD log
>>  		   this error. Well, it is reasonable.
>>  		 */
>> -		LIMIT_NETDEBUG(KERN_INFO "IPv6: udp checksum is 0\n");
>> +		LIMIT_NETDEBUG(KERN_INFO "IPv6: udp checksum is 0 [%pI6c > %pI6c]=
\n",
>> +			       &ipv6_hdr(skb)->saddr, &ipv6_hdr(skb)->daddr);
>
> Might be useful to mirror the ipv4 form and add port #'s too.

Good point. New version coming up.



Bj=C3=B8rn
