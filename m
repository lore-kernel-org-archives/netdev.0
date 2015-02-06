From: "Carlos O'Donell" <carlos@redhat.com>
Subject: Re: [Patch net-next] ipv6: fix redefinition of in6_pktinfo and ip6_mtuinfo
Date: Fri, 06 Feb 2015 00:29:14 -0500
Message-ID: <54D4512A.5080809@redhat.com>
References: <1420587932-8733-1-git-send-email-xiyou.wangcong@gmail.com> <20150108.193819.258816805892789860.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-7
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, vlee@twopensource.com
To: David Miller <davem@davemloft.net>, xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56415 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750766AbbBFF3U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Feb 2015 00:29:20 -0500
In-Reply-To: <20150108.193819.258816805892789860.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/08/2015 10:38 PM, David Miller wrote:
> From: Cong Wang <xiyou.wangcong@gmail.com>
> Date: Tue,  6 Jan 2015 15:45:31 -0800
>=20
>> Both netinet/in.h and linux/ipv6.h define these two structs,
>> if we include both of them, we got:
>>
>> 	/usr/include/linux/ipv6.h:19:8: error: redefinition of =A1struct in=
6_pktinfo=A2
>> 	 struct in6_pktinfo {
>> 		^
>> 	In file included from /usr/include/arpa/inet.h:22:0,
>> 			 from txtimestamp.c:33:
>> 	/usr/include/netinet/in.h:524:8: note: originally defined here
>> 	 struct in6_pktinfo
>> 		^
>> 	In file included from txtimestamp.c:40:0:
>> 	/usr/include/linux/ipv6.h:24:8: error: redefinition of =A1struct ip=
6_mtuinfo=A2
>> 	 struct ip6_mtuinfo {
>> 		^
>> 	In file included from /usr/include/arpa/inet.h:22:0,
>> 			 from txtimestamp.c:33:
>> 	/usr/include/netinet/in.h:531:8: note: originally defined here
>> 	 struct ip6_mtuinfo
>> 		^
>> So similarly to what we did for in6_addr, we need to sync with
>> libc header on their definitions.
>>
>> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
>=20
> Applied.
>=20

When does this hit mainline? I've got Cong's patch ready for glibc, but
the usual procedure is to commit after mainline has the matching patch.
Not that it really matters, but it's just a useful thing to be able to
say the trickle down is linux->glibc.

Cheers,
Carlos.
