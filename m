From: jamal <hadi@cyberus.ca>
Subject: tun device - bug or feature? WAS(Re: IMQ / new Dummy device post.
Date: 24 Apr 2004 10:14:43 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1082816083.1054.32.camel@jzny.localdomain>
References: <wazza.87ad18jbdl.fsf@message.id>
	 <1082427350.1034.70.camel@jzny.localdomain>
	 <wazza.87fzayw1fy.fsf@message.id> <wazza.87fzaxmr6x.fsf@message.id>
	 <wazza.87hdvddqxq.fsf@message.id>
	 <1082639764.1059.81.camel@jzny.localdomain>
	 <87oepjx65r.87n053x65r@87llknx65r.message.id>
	 <1082719745.1057.27.camel@jzny.localdomain>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: syrius.ml@no-log.org, Maxim Krasnyansky <maxk@qualcomm.com>,
        Jeff Garzik <jgarzik@pobox.com>, "David S. Miller" <davem@redhat.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <1082719745.1057.27.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Maxim,

When TUN_TUN_DEV is used, before the packet is injected into
the netif_rx() only skb->mac.raw = skb->data is set; the other headers
are not adjusted. Typically netdevs would do a
skb_pull(skb,dev->hard_header_len) to make the adjustment.
I have a feeling this is design intent thats why i didnt send you a
patch. 
Jeff, Dave: Would it be fair to say when packets get injected into the
stack by a netdev via netif_rx(), the skb headers are expected to be
ponting into some specific places? I am not sure if theres a hard
fastened rule defined anywhere.

cheers,
jamal

On Fri, 2004-04-23 at 07:29, jamal wrote:
> Hi there,
> 
> On Thu, 2004-04-22 at 13:43, syrius.ml@no-log.org wrote:
> > Hi,
> > 
> > It oops when using the ingress qdisc + action mirred egress redirect
> > filter on tun0. (no egress at all, no ingress on eth0)
> > It doesn't oops using an ingress qdisc + a simple police+drop filter
> > on tun0...
> 
> Ok, so you have narrowed it down to mirred, tun and ingress qdisc - is
> that correct? Were you using openvpn to recreate this?
> BTW, would this happen if you dont issue the ping -f initially in above
> setup? If yes, before you send create the problem can you send a few
> pings through tap device and send me output of dmesg?
> 
> I just did a simple test with a basic program and couldnt reproduce it.
> I dont have the proper setup, can you do a basic test with some other
> tunneling s/ware? 
> The doc for tun mentions: 
> http://vtun.sourceforge.net and http://perso.enst.fr/~beyssac/pipsec/
> Please compile in tun and dummy into the kernel.
> 
> BTW, i think we should take this offline; send your response directly to
> me. Anyone else interested in this conversation email both of us and we
> will cc you.
> 
> cheers,
> jamal
> 
> 
> 
> 
