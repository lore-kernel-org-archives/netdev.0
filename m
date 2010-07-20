From: Roy Marples <roy@marples.name>
Subject: Re: recv(2), MSG_TRUNK and kernels older than 2.6.22
Date: Tue, 20 Jul 2010 11:04:43 +0100
Message-ID: <4C4574BB.2010202@marples.name>
References: <4C455DC3.1050304@marples.name>	 <1279616099.2498.9.camel@edumazet-laptop>  <4C45678A.4080408@marples.name>	 <1279617873.2498.13.camel@edumazet-laptop> <1279620171.2498.30.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from uberserver.marples.name ([77.75.106.61]:65420 "EHLO
	uberserver.marples.name" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761166Ab0GTKEq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jul 2010 06:04:46 -0400
In-Reply-To: <1279620171.2498.30.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 20/07/2010 11:02, Eric Dumazet wrote:
> Le mardi 20 juillet 2010 =C3=A0 11:24 +0200, Eric Dumazet a =C3=A9cri=
t :
>> Le mardi 20 juillet 2010 =C3=A0 10:08 +0100, Roy Marples a =C3=A9cri=
t :
>>> On 20/07/2010 09:54, Eric Dumazet wrote:
>>>> Is it for the dhcpcd problem we talk about few week ago, disturbed=
 by
>>>> new 64bit stats ?
>>>
>>> Yes
>>>
>>>>
>>>> Why do you want to have a fixed size of 256 bytes ?
>>>>
>>>> Using 8192 bytes on stack would avoid MSG_TRUNK mess.
>>>
>>> Yes it would, but that doesn't answer my question :)
>>
>> Your question might be wrong ? :=3D)
>>
>>> I would like to use a buffer big enough, but not a whole 8k in size=
=2E
>>> dhcpcd has quite a small runtime and I'd like to keep it that way.
>>
>> 8192 bytes on stack is too much for you ?
>>
>> Then you should automatically resize your buffer, and not using
>> MSG_TRUNK at all (there is no guarantee the information you need wil=
l be
>> part of the truncated part)
>>
>>
>
> On<  2.6.22 kernels, recv() returns the length of your buffer, not si=
ze
> of netlink frame.
>
> You'll need something like :
>
> size_t sz =3D 256;
> char *buf =3D malloc(sz);
> while (1) {
> 	if (!buf) error();
> 	len =3D recv(fd, buf, sz, MSG_PEEK | MSG_TRUNC);
> 	if (len<  sz)
> 		break;
> 	if (len =3D=3D sz)
> 		sz *=3D 2; // old kernel, try to double size
> 	else
> 		sz =3D len; // recent kernel is nice with us
> 	buf =3D realloc(buf, sz);
> }
> len =3D recv(fd, buf, sz, 0);

Thankyou

If buf is NULL and sz is 0, would 0 still be returned? I'm guessing so.

Thanks

Roy
