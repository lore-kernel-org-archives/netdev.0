From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] af_pppox: create module infrastructure for protocol
 modules
Date: Mon, 28 Apr 2003 22:27:28 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030428.222728.48508327.davem@redhat.com>
References: <20030429061227.GJ25361@conectiva.com.br>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mostrows@speakeasy.net, netdev@oss.sgi.com, maxk@qualcomm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: acme@conectiva.com.br
In-Reply-To: <20030429061227.GJ25361@conectiva.com.br>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
   Date: Tue, 29 Apr 2003 03:12:27 -0300

   	Max, take a look and see if this same approach can be used in
   bluetooth, I bet it can, its just a matter of not using struct
   net_proto_family for bt_proto, just like pppox already was doing
   before my changes :-)

Something similar can be done for ipv4/ipv6 by adding a struct module
*owner member to struct inet_protosw etc. etc.

Although the idea is conceptually sound, you miss one crucial thing.
Such struct sock's reference _TWO_ modules, the "PPPOE" module
and the "PPPOX" module.

So in the TCP/UDP/SCTP example case, a struct sock references the
TCP/UDP/SCTP module _AND_ the ipv4/ipv6 module.

So what we'll need to do is use two owner pointers in struct sock,
one for propagating the "struct socket" owner, and one for the
"sub-protocol".

	struct module	*owner;
	struct module	*sub_owner;
