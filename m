From: "David S. Miller" <davem@davemloft.net>
Subject: Re: af_packet.c bug?
Date: Mon, 28 Mar 2005 12:18:06 -0800
Message-ID: <20050328121806.3208ac40.davem@davemloft.net>
References: <424858D4.8060604@candelatech.com>
	<20050328195557.GF3086@postel.suug.ch>
	<4248642E.40304@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <4248642E.40304@candelatech.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 28 Mar 2005 12:08:14 -0800
Ben Greear <greearb@candelatech.com> wrote:

> I was also wondering why we couldn't hold a reference to the net-device
> instead of just it's ifindex when dealing with a bound raw socket.

Because then raw sockets could make unloading of netdevices
hang forever.  That is, unless you add some netdev notifier
to af_packet.c that walks all the raw sockets looking for netdev
references.

I guess it also would make things like leaving a dump running
while you quickly down/up and interface stop working.
