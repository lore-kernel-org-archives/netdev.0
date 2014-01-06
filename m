From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH V1 net-next 2/2] net: Add UDP GRO support for vxlan traffic
Date: Mon, 6 Jan 2014 08:50:12 -0800
Message-ID: <CA+mtBx_B+7CU3GDiod+n7tHfwBcA_3DEhD7tvPYhsZMebiwY8w@mail.gmail.com>
References: <1388935422-7331-1-git-send-email-ogerlitz@mellanox.com>
	<1388935422-7331-3-git-send-email-ogerlitz@mellanox.com>
	<CA+mtBx-g1tsBEG6D0oOmG-J_fz68fr6py2OY6RAtoJHUts7h3g@mail.gmail.com>
	<CAJZOPZJ2DRP13LRzcu__rh=JxY7oAvCQ37dCpmO40ptiRn5hFw@mail.gmail.com>
	<CAJZOPZLZNEvao9PxtX78sfpg_4GVamgxNMNU52QQ1aFqAxQDZA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Or Gerlitz <ogerlitz@mellanox.com>, Jerry Chu <hkchu@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Yan Burman <yanb@mellanox.com>,
	Shlomo Pongratz <shlomop@mellanox.com>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f181.google.com ([209.85.223.181]:62538 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751115AbaAFQuM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jan 2014 11:50:12 -0500
Received: by mail-ie0-f181.google.com with SMTP id e14so17811904iej.26
        for <netdev@vger.kernel.org>; Mon, 06 Jan 2014 08:50:12 -0800 (PST)
In-Reply-To: <CAJZOPZLZNEvao9PxtX78sfpg_4GVamgxNMNU52QQ1aFqAxQDZA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 6, 2014 at 8:38 AM, Or Gerlitz <or.gerlitz@gmail.com> wrote:
> On Mon, Jan 6, 2014 at 3:32 PM, Or Gerlitz <or.gerlitz@gmail.com> wrote:
>> As the GUE RFC states, with UDP encapsulation, the encap protocol is
>> actually derived from the UDP destination port. With that assumption
>> at hand, we can have the udp gro code to export callbacks for upper
>> uncapsulation protocol to install a gro handler which has the
>> following trivial strucure:
>>
>> key = <PORT>  data = <gro receive/complete callbacks>
>
>> which plugs nicely into the general framework of the gro stack. The
>> udp gro receive code would act as follows
>> -- if there's no gro handler set for the packet udp dest port, flush
>> - do the normal loop to find match on the packet dest/src udp ports
>> - call the protocol (e.g VXLAN) gro receive callback
>> This would avoid dealing with sockets etc and be very efficient, makes sense?
>
> Or in short -- the destination udp port takes a similar role to the
> ethertype for gro l3 handlers or the ip protocol for gro l4 handlers
> and we enable encapsulating protocols to plug into the existing
> offload_callbacks framework, simple.

I think this would be a good start. We can further optimize the encap
path later on.
