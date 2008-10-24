From: "Todd Hayton" <todd.hayton@gmail.com>
Subject: Re: IPv6 multicast forwarding
Date: Fri, 24 Oct 2008 09:06:49 -0400
Message-ID: <50a66e370810240606ncb3dcd6gc949b734b1dcf488@mail.gmail.com>
References: <50a66e370810231511m10a10ca2oa870e9fbd55f4b0e@mail.gmail.com>
	 <20081024111044.74c15155@varda>
	 <alpine.LRH.2.00.0810241307360.1106@netcore.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "=?ISO-8859-1?Q?Alejandro_Riveira_Fern=E1ndez?=" <ariveira@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "Pekka Savola" <pekkas@netcore.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.156]:50001 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751778AbYJXNGv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Oct 2008 09:06:51 -0400
Received: by fg-out-1718.google.com with SMTP id 19so963394fgg.17
        for <netdev@vger.kernel.org>; Fri, 24 Oct 2008 06:06:49 -0700 (PDT)
In-Reply-To: <alpine.LRH.2.00.0810241307360.1106@netcore.fi>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 24, 2008 at 6:12 AM, Pekka Savola <pekkas@netcore.fi> wrote=
:
> On Fri, 24 Oct 2008, Alejandro Riveira Fern=E1ndez wrote:
>>>
>>> Let me apologize in advance for the length of this message - it is =
long!
>>>
>>> I'm trying to test out IPv6 multicast forwarding on a 2.6.26 kernel
>>> and I'm getting some strange values for the upcall messages from th=
e
>>> kernel. My code is below, but to give an overview, my setup is as
>>> follows:
>>>
>>>    sender ------ ff15::1 -----> [eth1] linux 2.6.26 [eth0] ------> =
=2E..
>
> Maybe this isn't the bug you're looking for but you shouldn't be usin=
g ff1x
> multicast addresses in a test like this; ff1x means that the multicas=
t group
> is of "interface-local scope" and it isn't useful for multicast forwa=
rding.
>  So the kernel might be correct in not installing multicast forwardin=
g state
> for a group address like this (but if it's a conscious decision, mayb=
e the
> failure mode should be better).  See S 2.7 of RFC4291.
>

Hey there, thanks for the response! I may be misinterpreting the RFC
but I thought ff15::1 was a site-local address. As in I break down
ff15::1 as follows -

0xff : identifies the address as multicast
0x15 : 4-bits flags and 4-bits scope where
  flags =3D 0x1 meaning that the T bit is set as this address is not a
permanently assigned address
  scope =3D 0x5 indicating site-local scope

Todd H


> --
> Pekka Savola                 "You each name yourselves king, yet the
> Netcore Oy                    kingdom bleeds."
> Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
