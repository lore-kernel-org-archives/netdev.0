From: Masakazu Mokuno <mokuno-DfbDroY8Xu1L9jVzuh4AOg@public.gmane.org>
Subject: Re: : Emit event stream compat iw_point objects correctly.
Date: Thu, 27 Dec 2007 18:24:40 +0900
Message-ID: <20071227181439.6F59.40F06B3A@sm.sony.co.jp>
References: <20071227173802.6F56.40F06B3A@sm.sony.co.jp> <20071227.005725.144782426.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20071227.005725.144782426.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


On Thu, 27 Dec 2007 00:57:25 -0800 (PST)
David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> wrote:

> From: Masakazu Mokuno <mokuno-DfbDroY8Xu1L9jVzuh4AOg@public.gmane.org>
> Date: Thu, 27 Dec 2007 17:51:49 +0900
> 
> > 	Hi
> > 
> > On Fri, 21 Dec 2007 20:58:08 -0800 (PST)
> > David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> wrote:
> > 
> > > @@ -520,7 +530,7 @@ iwe_stream_add_point(char *	stream,		/* Stream of events */
> > >  		memcpy(stream + IW_EV_LCP_LEN,
> > >  		       ((char *) iwe) + IW_EV_LCP_LEN + IW_EV_POINT_OFF,
> > >  		       IW_EV_POINT_PK_LEN - IW_EV_LCP_PK_LEN);
> > 
> > As the alignment of 64bit platforms may be defferent from 32bit one,
> > should it be like the following?
> 
> IW_EV_LCP_LEN is the same on both 32-bit and 64-bit platforms, it is
> just the size of the "len" and "cmd" portions of struct iw_event.
> 

IW_EV_LCP_PK_LEN ?

#define IW_EV_LCP_PK_LEN        (4)

> Those are both __u16, so IW_EV_LCP_LEN always evaluates to "4",
> try it if you do not believe me. :-)

Although I believed you, I tried :)

On ppc64 (PS3), IW_EV_LCP_LEN is 8, not 4.

include/linux/wireless.h:

#define IW_EV_LCP_LEN   (sizeof(struct iw_event) - sizeof(union iwreq_data))

where sizeof(struct iw_event) == 24, sizeof(union iwreq_data) == 16 on
PS3.

-- 
Masakazu MOKUNO
