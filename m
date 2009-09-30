From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: Re: mac80211: NOHZ: local_softirq_pending 08
Date: Wed, 30 Sep 2009 17:10:28 +0200
Message-ID: <200909301710.31082.mb@bu3sch.de>
References: <200909111648.50902.mb@bu3sch.de> <87ocosqykb.fsf@purkki.valot.fi> <1254322466.3959.5.camel@johannes.local>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Kalle Valo <kalle.valo-X3B1VOXEql0@public.gmane.org>,
	Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1254322466.3959.5.camel-YfaajirXv2244ywRPIzf9A@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wednesday 30 September 2009 16:54:26 Johannes Berg wrote:
> On Wed, 2009-09-30 at 17:47 +0300, Kalle Valo wrote:
> 
> > I agree with Michael. The bug is real and I have verified that
> > Michael's patch fixes the issue. Better to apply the patch now, it's
> > trivial to change the implementation if/when the network stack has
> > support for this.
> 
> FWIW, I think in mac80211 the in_interrupt() check can never return true
> since we postpone all RX to the tasklet. But the tasklet seems to be ok
> -- so should it really be in_interrupt()?

I think a tasklet is also in_interrupt(), because it's a softirq.
in_interrupt() returns false in process context. The problem appeared when
the b43 driver started passing RX frames while being in process context (threaded IRQ).
It previously was in tasklet (= softirq) context.

-- 
Greetings, Michael.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
