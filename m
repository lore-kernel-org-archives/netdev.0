From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] net: filter: Just In Time compiler
Date: Thu, 14 Apr 2011 18:05:47 +0200
Message-ID: <1302797147.3248.32.camel@edumazet-laptop>
References: <1301783301.2837.77.camel@edumazet-laptop>
	 <1301784797.3110.4.camel@localhost>
	 <1301838968.2837.200.camel@edumazet-laptop> <4DA70743.1050106@redhat.com>
	 <0a7fdea6b816da546ea71f752d36b5c2@localhost> <4DA715BB.6050307@redhat.com>
	 <1302795951.3248.14.camel@edumazet-laptop> <4DA71876.803@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Hagen Paul Pfeifer <hagen@jauu.net>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Ben Hutchings <bhutchings@solarflare.com>
To: Avi Kivity <avi@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:60491 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758736Ab1DNQFv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2011 12:05:51 -0400
Received: by wwa36 with SMTP id 36so2195989wwa.1
        for <netdev@vger.kernel.org>; Thu, 14 Apr 2011 09:05:50 -0700 (PDT)
In-Reply-To: <4DA71876.803@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 14 avril 2011 =C3=A0 18:53 +0300, Avi Kivity a =C3=A9crit :

> IMO, it will.  I'll try to have gcc optimize your example filter late=
r.

Sure you can JIT a C program from bpf. It should take maybe 30 minutes.
It certainly is more easy than JIT an binary/assembly code :)

Now take a look how I call slowpath, I am not sure gcc will actually
generate better code because of C conventions.

Loading a filter should be fast.
Invoking a compiler is just too much work for BPF.
Remember loading a filter is available to any user.

This idea would be good for netfilter stuff, because we dont load
iptables rules that often.

But still, the netfilter mainloop can be converted as a kernel JIT, mos=
t
probably. All the complex stuff (matches, targets) must call external
procedures anyway.



