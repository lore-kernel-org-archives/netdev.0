From: Hannes Frederic Sowa <hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>
Subject: Re: linux-next: Tree for Aug 6 [ wireless | iwlwifi | mac80211 ? ]
Date: Tue, 6 Aug 2013 23:56:57 +0200
Message-ID: <20130806215657.GA16410@order.stressinduktion.org>
References: <CA+icZUV++2+OG=P1SVbNrpHPLyzrfFX0eu8NHrd0nPjkPDUOtQ@mail.gmail.com> <CA+icZUXpZaHu-FjR6FGnbkG0XEkiukEgYYbDmrSjdqNz4rWCNg@mail.gmail.com> <1375816128.8219.28.camel@jlt4.sipsolutions.net> <CA+icZUXaTYVc_iv3hny6Je9mVdX8KCVpFSNBeukS+Fh-347Wvw@mail.gmail.com> <1375816715.8219.29.camel@jlt4.sipsolutions.net> <CA+icZUXdAjEDgu2XrA4Dg2hsLDJYdFTCpJwiW6=ZUgULe2noyw@mail.gmail.com> <CA+icZUVmokQ1fKmtbuPyp7f5Z2wdFYfjG5HCAm4Kue7efyKV8w@mail.gmail.com> <20130806213006.078C72210F@mail.nwl.cc> <CA+icZUVk1HM-VVYcARvY7p5KBYz0YcY9+rW8s-nKPTeVYh4tgw@mail.gmail.com> <1375825538.10459.1.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: sedat.dilek-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Stephen Rothwell <sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org>,
	wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1375825538.10459.1.camel-8Nb76shvtaUJvtFkdXX2HixXY32XiHfO@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 06, 2013 at 11:45:38PM +0200, Johannes Berg wrote:
> On Tue, 2013-08-06 at 23:40 +0200, Sedat Dilek wrote:
> 
> > > Does the problem occur on client or server side? AFAICT, hostapd as well
> > > as wpa_supplicant use AF_PACKET.
> > >
> > > The tricky thing is, these patches are meant to *loosen* the
> > > restrictions in af_packet.c, so *should* not be harmful. So either my
> > > patches create a side effect I did not foresee, or it's something nasty
> > > (too much delay introduced by calling eth_type_trans() or so).
> 
> > By reverting the culprit commit my network/wifi is fine, again.
> > See also attached patch with changelog.
> 
> I think skb->protocol is probably getting set up wrong, and just putting
> back the last two lines
> 
>         skb->protocol = proto;
>         skb->dev = dev;
> 
> is probably sufficient to fix wifi. If skb->protocol isn't set to
> ETH_P_PAE, then we'd drop the packet in the wifi stack - might be worth
> printing out what it's set to at the point where the skb->protocol
> assignment above was removed.
> 
> I'm trying to wrap my head around all this right now but I don't yet see
> how the code after the patch would not get skb->protocol correct.

Has anybody tested plain ethernet? I have a malfunctioning dhclient on
ethernet since the weekend(it seems to not receive any packet). I did not
look after it because have other patches on my todo list currently. Maybe
it is the same error?

Greetings,

  Hannes

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
