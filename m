From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] fix outstanding ref's preventing ether driver unload
Date: Tue, 23 Dec 2003 15:11:54 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031223151154.01fd002a.shemminger@osdl.org>
References: <OFB4EC53DF.8138874D-ON88256DF9.0082A560@us.ibm.com>
	<20031223142931.703d5c88.shemminger@osdl.org>
	<20031223143832.5fe65329.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: dlstevens@us.ibm.com, yoshfuji@linux-ipv6.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20031223143832.5fe65329.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 23 Dec 2003 14:38:32 -0800
"David S. Miller" <davem@redhat.com> wrote:

> On Tue, 23 Dec 2003 14:29:31 -0800
> Stephen Hemminger <shemminger@osdl.org> wrote:
> 
> > Patch against 2.6.0 to fix the problem of being unable to load the
> > ethernet driver because of reference's still being held.  The
> > problem reference's are from IPV6 network discovery packets that get
> > captured by the af_packet protocol and queued onto a socket queue
> > (which may never drain).  The route dst entries in the skbuff get
> > clone'd and won't be freed until the socket read.
> 
> Are you going to add such code to RAW, UDP, TCP, etc. etc.?

They don't have the problem because they don't go through the netdev_queue_xmit_nit
code path.  Audited all calls to dev_add_packet and AF_PACKET is the only
one that I found that could potentially register for ptype_all.

The same thing could happen through the loopback device, though.
But the loopback device can never be unloaded so it doesn't really
hurt anything.

> I understand the problem, but the point I'm making here is that
> I see nothing which makes it specific to AF_PACKET.

AF_PACKET is the only one (today) that can take packets intended
for a real device and end up queueing them to user space.

> This brings us back to an old and sore topic, which is the
> dst_dev_event() code in net/core/dst.c, have you had a look
> at that?

Yes, I did look at that but it wasn't the problem here. 
