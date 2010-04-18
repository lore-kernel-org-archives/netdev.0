From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH v5] rfs: Receive Flow Steering
Date: Sun, 18 Apr 2010 08:06:44 +0800
Message-ID: <h2q412e6f7f1004171706w905cc5c8u51f82cad221642f4@mail.gmail.com>
References: <alpine.DEB.1.00.1004152243470.15102@pokey.mtv.corp.google.com>
	<20100415.233334.242114544.davem@davemloft.net> <1271401007.16881.3762.camel@edumazet-laptop>
	<l2m65634d661004161135h1c1466afi54787022bfc2ce12@mail.gmail.com>
	<1271443994.16881.4249.camel@edumazet-laptop> <u2t65634d661004161342zeadb5602w73c369ec717dc6e1@mail.gmail.com>
	<1271452358.16881.4486.camel@edumazet-laptop> <1271520633.16881.4754.camel@edumazet-laptop>
	<h2h65634d661004171038g75160e7avae118dfd1cb1441d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f197.google.com ([209.85.223.197]:48951 "EHLO
	mail-iw0-f197.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755866Ab0DRAHI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Apr 2010 20:07:08 -0400
Received: by iwn35 with SMTP id 35so1218280iwn.21
        for <netdev@vger.kernel.org>; Sat, 17 Apr 2010 17:07:04 -0700 (PDT)
In-Reply-To: <h2h65634d661004171038g75160e7avae118dfd1cb1441d@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 18, 2010 at 1:38 AM, Tom Herbert <therbert@google.com> wrot=
e:
> That's cool!, but I still like the idea that this hash is treated as
> an opaque value getting the hash from the device to avoid the jhash
> or cache misses on the packet can also be a win... =C2=A0Maybe connec=
tion
> tracking/firewall could use the skb->rxhash which provides the
> consistency and also eliminates the need to do more jhashes.
>

consistent rxhash only adds the risk of the hash collision, and I
don't think it is a big problem. For connection tracking/firewall use,
I am afraid that we have to recompute this value after defrag.  So we
have to export the hash function we used in RPS.

As NIC's hash function can be changed dynamically, the rxhash isn't
consistent, so the rxhash can't be used by connection tracking, socket
lookup and others come later.

--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
