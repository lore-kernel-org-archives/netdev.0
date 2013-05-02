From: Dan Williams <dcbw@redhat.com>
Subject: Re: [GIT] Networking
Date: Thu, 02 May 2013 13:24:26 -0500
Message-ID: <1367519066.7757.19.camel@dcbw.foobar.com>
References: <20130501.164755.1859264969403837546.davem@davemloft.net>
	 <CA+55aFzsvyQLLKbuETBqfhpgkSaXH9cvT0O-cQ-mTTXXxcMqwg@mail.gmail.com>
	 <1367512467.4000.7.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	hayeswang <hayeswang@realtek.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1367512467.4000.7.camel@dcbw.foobar.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2013-05-02 at 11:34 -0500, Dan Williams wrote:
> On Wed, 2013-05-01 at 18:28 -0700, Linus Torvalds wrote:
> > On Wed, May 1, 2013 at 1:47 PM, David Miller <davem@davemloft.net> wrote:
> > >
> > > Highlights (1721 non-merge commits, this has to be a record of some
> > > sort):
> > 
> > Lowlight: it completely breaks my machine with r8169 ethernet.  In the
> > networkmanager applet, it claims no cable connection, which is a bit
> > odd, because (a) it works with an older kernel and (b) the kernel
> > messages actually say
> > 
> >   r8169 0000:01:00.0 eth0: link up
> 
> NM calls ETHTOOL_GLINK and if that returns success, NM expects the
> driver to support carrier detection.  NM then listens to netlink for
> device flags changes, and uses IFF_LOWER_UP to determine carrier on/off
> state.  NM does not use NETIF_F_VLAN_CHALLENGED or any of the other
> ETHTOOL_GFEATURES flags yet, but will in the future.
> 
> Is the link status accurately reflected by /sys/class/net/eth0/carrier ?

One more question Linus; what version of NetworkManager, and can you
grab some syslog 'daemon' facility logs grepped for "
NetworkManger" | "eth0"?

When r8169 says "link up" I would expect
that /sys/class/net/eth0/carrier is '1', and that NetworkManager then
prints something in the logs about "carrier is ON".  Output of the eth0
section of 'nm-tool' would be useful here as well, specifically the
"State" and "Carrier" lines.

Dan

> Dan
> 
> 
> > but nothing actually works.
> > 
> >  r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
> >  r8169 0000:01:00.0 eth0: RTL8168d/8111d at 0xffffc90010ece000,
> > e0:cb:4e:95:1a:d7, XID 083000c0 IRQ 53
> >  r8169 0000:01:00.0 eth0: jumbo features [frames: 9200 bytes, tx
> > checksumming: ko]
> > 
> > Any ideas?
> > 
> >                   Linus
> > --
> > To unsubscribe from this list: send the line "unsubscribe netdev" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
