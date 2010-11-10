From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: sk->sk_socket seems to disappear before connection termination
Date: Wed, 10 Nov 2010 18:17:56 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1011101816330.2886@obet.zrqbmnf.qr>
References: <alpine.LNX.2.01.1011100205220.17978@obet.zrqbmnf.qr>  <1289368037.2700.14.camel@edumazet-laptop>  <alpine.LNX.2.01.1011101148060.18018@obet.zrqbmnf.qr> <1289407451.2860.239.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Howells <dhowells@redhat.com>,
	Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>, netdev@vger.kernel.org,
	=?UTF-8?Q?Rafa=C5=82_Maj?= <rafal.maj.it@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1289407451.2860.239.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Wednesday 2010-11-10 17:44, Eric Dumazet wrote:
>
>[ 9920.234680] ipt_LOG: sk=ffff880118bd32c0 sk->sk_socket=ffff88011d0d8c00 file=ffff88011cd4e100
>[ 9920.234731] IN= OUT=eth1 SRC=192.168.20.108 DST=192.168.20.110 LEN=52 TOS=0x10 PREC=0x00 TTL=64 ID=63704 DF PROTO=TCP SPT=60088 DPT=22 WINDOW=35 RES=0x00 ACK FIN URGP=0 UID=0 GID=0 
>[ 9920.235221] ipt_LOG: sk=ffff880078998000 sk->sk_socket=ffff880078c58300 file=          (null)
>[ 9920.235271] IN= OUT=eth1 SRC=192.168.20.108 DST=192.168.20.110 LEN=52 TOS=0x00 PREC=0x00 TTL=64 ID=0 DF PROTO=TCP SPT=60088 DPT=22 WINDOW=35 RES=0x00 ACK URGP=0 
>
>You can see in my log, that the last packet seems to be from a different
>socket ! (sk pointer changed to ffff880078998000 !)

Yes, that's it.

>Well well well, thats an ACK, in answer to FIN packet received from remote
>side.

But why is it not handled by sk ffff880118bd32c0 anymore?
It does have, after all, the same (addr,port) tuple.
And it is sort of a hiccup for xt_owner users.
