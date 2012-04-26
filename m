From: Tore Anderson <tore@fud.no>
Subject: Re: [PATCH net-next] ipv6: =?UTF-8?Q?RTAX=5FFEATURE=5FALLFRAG=20c?=  =?UTF-8?Q?auses=20inefficient=20TCP=20segment=20sizing?=
Date: Thu, 26 Apr 2012 12:32:17 +0200
Message-ID: <0e135d034e75f56cb6d5318595c17023@greed.fud.no>
References: <1335289058.5205.165.camel@edumazet-glaptop>
 <CANP3RGd0mV8RcH1zCLBg+N9sgPGbiynhOSfoUAYpcMgYsvzeNA@mail.gmail.com>
 <1335298228.5205.168.camel@edumazet-glaptop>
 <CANP3RGfhc+4FjB152r58AP66oZQmj0oY-Zh=9qNn9OABCXPwbw@mail.gmail.com>
 <1335331960.5205.180.camel@edumazet-glaptop>
 <CANP3RGdhs8s_RytR=f8ismSZdGs91bpVq=ZAjb0EOm-gCsDPAw@mail.gmail.com>
 <f88609a3e80bbe53233e62dec2699a3e@greed.fud.no>
 <CANP3RGcGH6Su8Lvt34eTDF2iv2HSipo2DvybXGQA4pXZj_qb9Q@mail.gmail.com>
 <4c435f101fb7c653fd3b4e81980250e7@greed.fud.no>
 <CANP3RGf5oTd9mQsXqKj3uXgweMwjs9N3VSeXBHjDXQ7vG0NaSg@mail.gmail.com>
 <1335350667.3274.53.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <maze@google.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from greed.fud.no ([87.238.35.20]:35151 "EHLO greed.fud.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755527Ab2DZKcW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Apr 2012 06:32:22 -0400
In-Reply-To: <1335350667.3274.53.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Eric Dumazet

> Yes, in fact we are going to keep the allfrag feature, and arm it if 
> we
> receive an mtu < 512.

One thing to think about if you go down this path is to keep track of 
the PMTU received in the ICMPv6 PTB. If you activate the allfrag feature 
on a destination because you received a PTB with PMTU=400, it's not 
useful to include the Fragmentation header in packets <400 bytes in 
size, for example.

With the current code, even tiny packets without any L4 payload (e.g. 
TCP SYN/ACK) will have the Fragmentation header added. That's not 
optimal, but necessary since the current code does not keep track of the 
actual PMTU if it is <1280 as far as I can tell (instead it discards the 
received PMTU value, clamps the effective PMTU to 1280, and enables 
allfrag).

Tore
