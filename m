From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH] Disable router anycast address for /127 prefixes
Date: Fri, 01 Jul 2011 15:09:57 -0400
Message-ID: <4E0E1B85.1080906@hp.com>
References: <20110630104713.52e085dd@nehalam.ftrdhcpuser.net>	<1309519330-16649-1-git-send-email-bjorn@mork.no>	<4E0DDDA5.20401@hp.com> <87y60hsvr2.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?UTF-8?B?QmrDuHJuIE1vcms=?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0009.atlanta.hp.com ([15.192.0.46]:2813 "EHLO
	g5t0009.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755316Ab1GATRF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2011 15:17:05 -0400
In-Reply-To: <87y60hsvr2.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/01/2011 02:26 PM, Bj=C3=B8rn Mork wrote:
> Brian Haley <brian.haley@hp.com> writes:
>> On 07/01/2011 07:22 AM, Bj=C3=B8rn Mork wrote:
>>> RFC 6164 requires that routers MUST disable Subnet-Router anycast
>>> for the prefix when /127 prefixes are used.
>>>
>>> Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
>>> ---
>>
>>> @@ -1479,6 +1481,8 @@ static void addrconf_join_anycast(struct inet=
6_ifaddr *ifp)
>>>  static void addrconf_leave_anycast(struct inet6_ifaddr *ifp)
>>>  {
>>>  	struct in6_addr addr;
>>> +	if (ifp->prefix_len =3D=3D 127) /* RFC 6164 */
>>> +		return;
>>>  	ipv6_addr_prefix(&addr, &ifp->addr, ifp->prefix_len);
>>>  	if (ipv6_addr_any(&addr))
>>>  		return;
>>
>> I'm not sure you'd need this part as there shouldn't be a /127 in th=
e list to remove.
>=20
> I don't understand exactly what you mean here....=20

If you never add an anycast address when the prefix length is 127, the =
address
wouldn't be there when you went to remove it.  In other words, the call=
 to
__ipv6_dev_ac_dec() would return -ENOENT, which is ignored anyways.

It's not a common codepath so the two lines of code wouldn't hurt anyth=
ing
I guess...

-Brian
