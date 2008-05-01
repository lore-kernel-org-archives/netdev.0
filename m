From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: Re: mac80211 truesize bugs
Date: Thu, 1 May 2008 11:32:24 +0200
Message-ID: <200805011132.24399.mb@bu3sch.de>
References: <1209607368.7173.20.camel@johannes.berg> <200805011058.40197.mb@bu3sch.de> <1209632886.4008.8.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1209632886.4008.8.camel-YfaajirXv214zXjbi5bjpg@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thursday 01 May 2008 11:08:06 Johannes Berg wrote:
> 
> > Hm, unrelated to this...
> > But I am wondering what happens if the driver adds a device header to the skb.
> > Is that header then also passed up netif_rx()?
> > This doesn't happen for b43, as we use the DMA fragmentation to transmit the header,
> > but it might happen for zd1211rw and others.
> 
> Hmm. I thought we said that it was supposed to be removed again by the
> hardware before TX status reporting. That's what most drivers seem to do
> anyway.

Ok. I was not aware of that. Is that documented somewhere? I guess we can't WARN_ON()?

> > Seems the skb->destructor messes it up.
> 
> Actually, it seems to be outside of mac80211, I put in a WARN_ON() and
> got this:

Yeah looks like the destructor messes with the data/sizes and disagrees
with the way mac80211 handles stuff, in some way.

> Badness at include/linux/skbuff.h:392
> NIP: c026ea14 LR: c0273d54 CTR: c026e9e4
> REGS: edfc7c00 TRAP: 0700   Not tainted  (2.6.25-wl-06841-g6b3d5c6-dirty)
> MSR: 00029032 <EE,ME,IR,DR>  CR: 82022444  XER: 00000000
> TASK = edf50e20[3453] 'tcpdump' THREAD: edfc6000
> GPR00: 00000001 edfc7cb0 edf50e20 edfd7700 edfd7700 00000002 edfc7e75 03230306 
> GPR08: 02000100 00000168 4dff0200 00000150 22022442 100a6290 100783f8 10078e18 
> GPR16: 10078e14 10078e10 100a0000 00000000 00000000 bfe2c9d2 1004d320 bfe2c4b0 
> GPR24: 10165070 edfd7724 00000060 00000020 ed8157f0 edfd7700 ed8157f0 edfd7700 
> NIP [c026ea14] sock_rfree+0x30/0x94
> LR [c0273d54] skb_release_all+0x98/0x128
> Call Trace:
> [edfc7cb0] [10078e10] 0x10078e10 (unreliable)
> [edfc7cc0] [c0273d54] skb_release_all+0x98/0x128
> [edfc7cd0] [c0273034] __kfree_skb+0x18/0xc8
> [edfc7ce0] [c02760d0] skb_free_datagram+0x1c/0x54
> [edfc7cf0] [f264d068] packet_recvmsg+0x170/0x1e8 [af_packet]
> [edfc7d40] [c026b69c] sock_recvmsg+0xb8/0xf0
> [edfc7e30] [c026b9d0] sys_recvfrom+0x94/0x100
> [edfc7f00] [c026ca08] sys_socketcall+0x114/0x1dc
> [edfc7f40] [c00124cc] ret_from_syscall+0x0/0x38
> 
> johannes
> 



-- 
Greetings Michael.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
