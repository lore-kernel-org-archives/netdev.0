From: "Peter W. Morreale" <pmorreale@novell.com>
Subject: Re: High contention on the sk_buff_head.lock
Date: Thu, 19 Mar 2009 06:50:44 -0600
Message-ID: <1237467044.6926.27.camel@hermosa>
References: <49C16349.9030503@us.ibm.com>
	 <20090318.143844.173112261.davem@davemloft.net>
	 <49C16D7C.3080003@novell.com>
	 <20090318.180355.228447835.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: ghaskins@novell.com, vernux@us.ibm.com, andi@firstfloor.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-rt-users@vger.kernel.org, pmullaney@novell.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-rt-users-owner@vger.kernel.org>
In-Reply-To: <20090318.180355.228447835.davem@davemloft.net>
Sender: linux-rt-users-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2009-03-18 at 18:03 -0700, David Miller wrote:
> From: Gregory Haskins <ghaskins@novell.com>
> Date: Wed, 18 Mar 2009 17:54:04 -0400
> 
> > Note that -rt doesnt typically context-switch under contention anymore
> > since we introduced adaptive-locks.  Also note that the contention
> > against the lock is still contention, regardless of whether you have -rt
> > or not.  Its just that the slow-path to handle the contended case for
> > -rt is more expensive than mainline.  However, once you have the
> > contention as stated, you have already lost.
> 
> First, contention is not implicitly a bad thing.
> 
> Second, if the -rt kernel is doing adaptive spinning I see no
> reason why that adaptive spinning is not kicking in here to
> make this problem just go away.

The basic 'problem' with comparing RT adaptive spinning to non-rt
spinlocks is that if the lock owner is !oncpu, all spinners must break
and go to sleep, otherwise we (potentially) deadlock.  This does not
exist for non-rt spinners. 

Best,
-PWM


> 
> This lock is held for mere cycles, just to unlink an SKB from
> the networking qdisc, and then it is immediately released.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rt-users" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

