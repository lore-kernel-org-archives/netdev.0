From: "David S. Miller" <davem@redhat.com>
Subject: Re: dev->destructor
Date: Thu, 01 May 2003 09:55:20 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030501.095520.63025177.davem@redhat.com>
References: <20030501120815.25BE22C155@lists.samba.org>
	<20030501.040935.68070653.davem@redhat.com>
	<20030501175111.GF3387@conectiva.com.br>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rusty@rustcorp.com.au, kuznet@ms2.inr.ac.ru, shemminger@osdl.org,
   netdev@oss.sgi.com, wa@almesberger.net
Return-path: <netdev-bounce@oss.sgi.com>
To: acme@conectiva.com.br
In-Reply-To: <20030501175111.GF3387@conectiva.com.br>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
   Date: Thu, 1 May 2003 14:51:11 -0300
   
   Well, I think that because there are a graph of relationships here we perhaps
   can be safe by protecting just some of the higher level objects (e.g. struct
   sock, struct socket, struct net_device) while leaving some other lower level
   objects managed by those higher level ones, e.g. struct sk_buff managed by
   struct sock.

The graphs are unfortunately not completely connected.

For example, sk_buff's can be sent not assosciated with any socket.
Routing cache entries are not attached to any particular client,
similar with ARP/neighbour entires, and sk_buff's in turn hold
references to these things.

See, long ago we used to not do proper reference counting
on struct sock's.  We used to rely on graphs of relationships
and certain sock states to control destruction of these objects.
The networking was riddled with obscure bugs because of this.
