From: Jouni Malinen <jkmaline@cc.hut.fi>
Subject: Re: [PATCH] hostap: Fix null pointer dereference in
	prism2_pccard_card_present()
Date: Wed, 31 Aug 2005 19:10:39 -0700
Message-ID: <20050901021039.GK7781@jm.kir.nu>
References: <871x4dx2ry.fsf@litku.valo.iki.fi> <43124814.8010704@pobox.com>
	<20050829005331.GW7781@jm.kir.nu>
	<87slwq0xwa.fsf@litku.valo.iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: hostap@shmoo.com, netdev@vger.kernel.org,
	Jeff Garzik <jgarzik@pobox.com>
Return-path: <hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com>
To: Kalle Valo <Kalle.Valo@iki.fi>
Content-Disposition: inline
In-Reply-To: <87slwq0xwa.fsf@litku.valo.iki.fi>
List-Unsubscribe: <http://lists.shmoo.com/mailman/listinfo/hostap>,
	<mailto:hostap-request@shmoo.com?subject=unsubscribe>
List-Archive: <http://lists.shmoo.com/pipermail/hostap>
List-Post: <mailto:hostap@shmoo.com>
List-Help: <mailto:hostap-request@shmoo.com?subject=help>
List-Subscribe: <http://lists.shmoo.com/mailman/listinfo/hostap>,
	<mailto:hostap-request@shmoo.com?subject=subscribe>
Sender: hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com
Errors-To: hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com
List-Id: netdev.vger.kernel.org

On Wed, Aug 31, 2005 at 09:22:29PM +0300, Kalle Valo wrote:
> Jouni Malinen <jkmaline@cc.hut.fi> writes:
> > local->hw_priv was initialized only after the interrupt handler was
> > registered. This could trigger a NULL pointer dereference in
> > prism2_pccard_card_present() that assumed that local->hw_priv is always
> > set (and it should have been). Fix this by setting local->hw_priv before
> > registering the interrupt handler.
> 
> I was trying to test Jouni's patch but now I can't reproduce the oops
> with latest ieee80211-wifi branch and my NULL pointer check removed.
> Earlier I could reproduce it every time. Strange.

Triggering this race conditions requires that you are sharing the same
interrupt line with another device which is generating interrupts at the
same time as Host AP driver is initializing the card. I don't know
whether interrupt assignment could have changed in the latest version,
but I would guess more like cause would be a difference in, e.g., how
other devices are being used at the time Host AP driver was being
initialized.

-- 
Jouni Malinen                                            PGP id EFC895FA
