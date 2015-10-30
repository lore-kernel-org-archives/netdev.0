From: Marek Vasut <marex@denx.de>
Subject: Re: [PATCH] can: Use correct type in sizeof() in nla_put()
Date: Fri, 30 Oct 2015 16:33:11 +0100
Message-ID: <201510301633.11762.marex@denx.de>
References: <1446209299-6250-1-git-send-email-marex@denx.de> <201510301524.58411.marex@denx.de> <5633846B.30107@hartkopp.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Marc Kleine-Budde" <mkl@pengutronix.de>,
	linux-can@vger.kernel.org, Wolfgang Grandegger <wg@grandegger.com>,
	netdev@vger.kernel.org
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <5633846B.30107@hartkopp.net>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday, October 30, 2015 at 03:53:31 PM, Oliver Hartkopp wrote:
> On 10/30/2015 03:24 PM, Marek Vasut wrote:
> > On Friday, October 30, 2015 at 03:17:44 PM, Marc Kleine-Budde wrote:
> >> On 10/30/2015 03:01 PM, Marek Vasut wrote:
> >>> Are you absolutelly positive this doesn't break kernel ABI please ?
> >>> 
> >>> I am a little worried there, since the size of can_clock and
> >>> can_ctrlmode structures differ.
> >> 
> >> struct can_clock is a u32, see [1]
> >> struct can_ctrlmode is 2 x u32.
> >> 
> >> in libsocketcan[2] it's accessed like this:
> >>> 	memcpy(res,
> >>> 	
> >>> 		RTA_DATA(can_attr[IFLA_CAN_CLOCK]),
> >>> 		sizeof(struct can_clock));
> >> 
> >> I think it should be ok.
> > 
> > In that case, yes, it's good. Hopefully, noone wrote his own thing.
> 
> Fortunately ip from iproute2 does it similary:
> 
> https://git.kernel.org/cgit/linux/kernel/git/shemminger/iproute2.git/tree/i
> p/iplink_can.c#n338
> 
> 
> 	if (tb[IFLA_CAN_CLOCK]) {
> 		struct can_clock *clock = RTA_DATA(tb[IFLA_CAN_CLOCK]);
> 
> 		fprintf(f, "\n	  clock %d", clock->freq);
> 	}
> 
> As the clock is a read-only value kernel->userspace and nla_put creates its
> own small ID/length information each time we are REALLY LUCKY that this fix
> doesn't break the ABI in this case.
> 
> When can_clock would have been greater then can_ctrlmode we really had a
> problem ...
> 
> Thanks for caching this!

Yeah, I already had one leg in my asbestos trousers all right. Thanks for
double-checking this!

Best regards,
Marek Vasut
