From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: Undefined behaviour of connect(fd, NULL, 0);
Date: Mon, 5 Apr 2010 17:23:50 +0800
Message-ID: <w2n412e6f7f1004050223j3e15df91tcdf133670c636a85@mail.gmail.com>
References: <n2w412e6f7f1003312000o3a69802j120acd3946458517@mail.gmail.com>
	<20100401143805.1f83a161@notabene.brown> <x2j412e6f7f1003312116rd3b3ba96t31267545efe7660f@mail.gmail.com>
	<20100401.002319.236233308.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: neilb@suse.de, shemminger@vyatta.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:60854 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752002Ab0DEJYL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Apr 2010 05:24:11 -0400
Received: by gyg13 with SMTP id 13so1923511gyg.19
        for <netdev@vger.kernel.org>; Mon, 05 Apr 2010 02:24:10 -0700 (PDT)
In-Reply-To: <20100401.002319.236233308.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 1, 2010 at 3:23 PM, David Miller <davem@davemloft.net> wrot=
e:
>
> This seems logical, but I believe it is wrong.
>
> We already know for a fact that it is guarenteed to not work
> reliably for every single kernel in existence in the world
> right now.
>
> Every system. =C2=A0Ones that have been deployed for 10 years as
> well as those built from GIT 10 seconds ago.
>
> So you tell me, if you put this into an application that you
> wish to deploy anywhere, are you not being completely stupid?
>
> Therefore, if it's illogical to use this in an application, what valu=
e
> is there in starting to support it now in the kernel?
>
> I'll tell you, the value is absolutely zero.
>
> Yes we need to add the length check, but the behavior we give to this
> case as a result, is completely arbitrary. =C2=A0And I would in fact =
argue
> for a hard error in these cases.
>
> Simply mark it as invalid to call connect() this way.
>

I found this from the man page of FreeBSD's connect(2).

     Generally, stream sockets may successfully connect() only
     once; datagram sockets may use connect() multiple times to change =
their
     association.  Datagram sockets may dissolve the association by con=
necting
     to an invalid address, such as a null address.

And this from the man page of Darwin's connect(2).

     Datagram sockets may dissolve the association by connecting to an
     invalid address, such as a null address or an address with the add=
ress
     family set to AF_UNSPEC (the error EAFNOSUPPORT will be harmlessly
     returned).

Since null address behavior has been defined by the others. I think
Linux should be compatible with the others. So the  patch submitted on
this by me should not been applied. I'll work out another patch later.

--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
