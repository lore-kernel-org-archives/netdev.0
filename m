From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] PKT_SCHED: dsmark must take care of shared/cloned skbs
Date: Mon, 20 Dec 2004 17:02:22 -0800
Message-ID: <20041220170222.5ee14588.davem@davemloft.net>
References: <20041218170017.GH17998@postel.suug.ch>
	<1103487827.1048.188.camel@jzny.localdomain>
	<20041219203641.GL17998@postel.suug.ch>
	<41C687EE.1090205@trash.net>
	<1103552026.1048.324.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, tgraf@suug.ch, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1103552026.1048.324.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 20 Dec 2004 09:13:46 -0500
jamal <hadi@cyberus.ca> wrote:

> Certainly not a big deal; shouldnt care if once in a while tcpdump
> actually gets to see the real packet that went out the wire.

It's not just tcpdump.  Any modification of a the packet data
for a shared SKB is illegal, no matter where it occurs.
This can corrupt TCP packets, which share the transmitted
packet with the socket retransmit queue.

We have a similar problem with TSO and some gigabit cards whose
drivers muck with the iphdr->tot_len field on transmit.  I still
am not sure how I want to address that case yet.  Since transmitted
TCP data packets are always shared/cloned, we'll have to do a data
copy on every TSO send on these cards which frankly nullifies much
of the performance gain TSO gives.  If we end of fixing it via a copy
we'll probably need to seriously consider not doing TSO unless we
are doing sendfile.
