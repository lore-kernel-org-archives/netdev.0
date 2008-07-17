From: jamal <hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org>
Subject: Re: [PATCH 20/31]: pkt_sched: Perform bulk of qdisc destruction in
	RCU.
Date: Thu, 17 Jul 2008 09:35:32 -0400
Message-ID: <1216301732.4726.26.camel@localhost>
References: <20080717.051726.226040470.davem@davemloft.net>
	 <487F4327.1000107@trash.net>
Reply-To: hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <487F4327.1000107-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2008-17-07 at 15:03 +0200, Patrick McHardy wrote:

> Actions are also visible
> globally, so this might still be a problem, not sure though since
> they don't refer to their parent (haven't thought about it much yet).

Actions are fine because they are intended to be globaly shared.
[i.e A classifier on ethx with qdiscA:Y (in/egress) can share an action
with  classifer on  ethy with qdiscB:Z (eg/ingress)].
Like you i need to digest the patches to understand the impact on the
rest but one thing i did notice was the last patch (replacement of
pfifo_fast):
prioritization based on TOS/DSCP (setsockopt) would no longer work, some
user space code may suffer (routing daemons likely). One suggestion to
fix it is to load pfifo qdisc (which does what fifo_fast is attempting)
for drivers that are h/ware multiq capable.

cheers,
jamal

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
