From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] PKT_SCHED: dsmark must take care of shared/cloned skbs
Date: 22 Dec 2004 08:14:06 -0500
Message-ID: <1103721246.1093.39.camel@jzny.localdomain>
References: <20041218170017.GH17998@postel.suug.ch>
	 <1103487827.1048.188.camel@jzny.localdomain>
	 <20041219203641.GL17998@postel.suug.ch> <41C687EE.1090205@trash.net>
	 <1103552026.1048.324.camel@jzny.localdomain>
	 <20041220170222.5ee14588.davem@davemloft.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, tgraf@suug.ch, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20041220170222.5ee14588.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2004-12-20 at 20:02, David S. Miller wrote:
> On 20 Dec 2004 09:13:46 -0500
> jamal <hadi@cyberus.ca> wrote:
> 
> > Certainly not a big deal; shouldnt care if once in a while tcpdump
> > actually gets to see the real packet that went out the wire.
> 
> It's not just tcpdump.  Any modification of a the packet data
> for a shared SKB is illegal, no matter where it occurs.
> This can corrupt TCP packets, which share the transmitted
> packet with the socket retransmit queue.
> 
> We have a similar problem with TSO and some gigabit cards whose
> drivers muck with the iphdr->tot_len field on transmit.  I still
> am not sure how I want to address that case yet.  Since transmitted
> TCP data packets are always shared/cloned, we'll have to do a data
> copy on every TSO send on these cards which frankly nullifies much
> of the performance gain TSO gives.  If we end of fixing it via a copy
> we'll probably need to seriously consider not doing TSO unless we
> are doing sendfile.

Ok, makes sense. I can see how TSO may not be useful if you have to
copy. I suppose NICS with hardware based retransmits will behave
differently.

cheers,
jamal
