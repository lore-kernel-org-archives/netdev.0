From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 2/2] bluetooth : __rfcomm_dlc_close lock fix
Date: Wed, 02 Apr 2008 00:00:17 -0700 (PDT)
Message-ID: <20080402.000017.222512990.davem@davemloft.net>
References: <20080402060243.GB3050@darkstar.te-china.tietoenator.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davej-rdkfGonbjUTCLXcRTR1eJlpr/1R2p/CL@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org
To: hidave.darkstar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080402060243.GB3050-4/PLUo9XfK+r2/o/tYUWRb82SWQ1Dih0B/ovq0HbDYUAvxtiuMwx3w@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Dave Young <hidave.darkstar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Wed, 2 Apr 2008 14:02:43 +0800

> Lockdep warning will be trigged while rfcomm connection closing.
> 
> The locks taken in rfcomm_dev_add:
> rfcomm_dev_lock --> d->lock
> 
> In __rfcomm_dlc_close:
> d->lock --> rfcomm_dev_lock (in rfcomm_dev_state_change)
> 
> There's two way to fix it, one is in rfcomm_dev_add we first locking
> d->lock then the rfcomm_dev_lock
> 
> The other (in this patch), remove the locking of d->lock for
> rfcomm_dev_state_change because just locking "d->state = BT_CLOSED;"
> is enough.

Also applied, thanks a lot Dave!
