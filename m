From: Rusty Russell <rusty-8n+1lVoiYb80n/F98K4Iww@public.gmane.org>
Subject: Re: [PATCH] mac80211: rewrite fragmentation code
Date: Mon, 19 May 2008 13:08:13 +1000
Message-ID: <200805191308.14548.rusty@rustcorp.com.au>
References: <200805161201.48835.rusty@rustcorp.com.au> <200805162032.48469.rusty@rustcorp.com.au> <20080516.124039.253626477.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org, mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org,
	johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ron.rindjunsky-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, tomasw-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	ivdoorn-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, peter.p.waskiewicz.jr-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080516.124039.253626477.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Saturday 17 May 2008 05:40:39 David Miller wrote:
> My description describes how I want the mid-layer queue to disappear
> entirely.  Queueing would be done by the driver only.

Ok, the more I ponder this, the more I like it.  It has a very nice side 
benefit for virtio_net: we can xmit a whole bunch of packets before notifying 
the host.  Real NICs might gain similarly.

The bit I can't see is what to do about qdisc if the driver manages its own 
queue(s).  Leave the qdisc as currently in place and have the driver call 
dev_dequeue_skb() (or some wrapper) directly?  Modulo locking issues, that 
should be a fairly simple change.

Thanks,
Rusty.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
