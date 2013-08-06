From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: linux-next: Tree for Aug 6 [ wireless | iwlwifi | mac80211 ? ]
Date: Tue, 06 Aug 2013 23:45:38 +0200
Message-ID: <1375825538.10459.1.camel@jlt4.sipsolutions.net>
References: <1375804998.8219.27.camel@jlt4.sipsolutions.net>
	 <CA+icZUVRgVfXUdJ1xoaN=nciqZDhV-f6EbH+6DS7HAh+My65oQ@mail.gmail.com>
	 <CA+icZUUmQbovkwXcdEp6eu=WJkiuiyO8nDVwCHFUuPDbJqU7Kg@mail.gmail.com>
	 <CA+icZUV++2+OG=P1SVbNrpHPLyzrfFX0eu8NHrd0nPjkPDUOtQ@mail.gmail.com>
	 <CA+icZUXpZaHu-FjR6FGnbkG0XEkiukEgYYbDmrSjdqNz4rWCNg@mail.gmail.com>
	 <1375816128.8219.28.camel@jlt4.sipsolutions.net>
	 <CA+icZUXaTYVc_iv3hny6Je9mVdX8KCVpFSNBeukS+Fh-347Wvw@mail.gmail.com>
	 <1375816715.8219.29.camel@jlt4.sipsolutions.net>
	 <CA+icZUXdAjEDgu2XrA4Dg2hsLDJYdFTCpJwiW6=ZUgULe2noyw@mail.gmail.com>
	 <CA+icZUVmokQ1fKmtbuPyp7f5Z2wdFYfjG5HCAm4Kue7efyKV8w@mail.gmail.com>
	 <20130806213006.078C72210F@mail.nwl.cc>
	 <CA+icZUVk1HM-VVYcARvY7p5KBYz0YcY9+rW8s-nKPTeVYh4tgw@mail.gmail.com>
	 (sfid-20130806_234032_528772_3836D785)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	wireless <linux-wireless@vger.kernel.org>, netdev@vger.kernel.org
To: sedat.dilek@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:56661 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756860Ab3HFVpr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Aug 2013 17:45:47 -0400
In-Reply-To: <CA+icZUVk1HM-VVYcARvY7p5KBYz0YcY9+rW8s-nKPTeVYh4tgw@mail.gmail.com> (sfid-20130806_234032_528772_3836D785)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-08-06 at 23:40 +0200, Sedat Dilek wrote:

> > Does the problem occur on client or server side? AFAICT, hostapd as well
> > as wpa_supplicant use AF_PACKET.
> >
> > The tricky thing is, these patches are meant to *loosen* the
> > restrictions in af_packet.c, so *should* not be harmful. So either my
> > patches create a side effect I did not foresee, or it's something nasty
> > (too much delay introduced by calling eth_type_trans() or so).

> By reverting the culprit commit my network/wifi is fine, again.
> See also attached patch with changelog.

I think skb->protocol is probably getting set up wrong, and just putting
back the last two lines

        skb->protocol = proto;
        skb->dev = dev;

is probably sufficient to fix wifi. If skb->protocol isn't set to
ETH_P_PAE, then we'd drop the packet in the wifi stack - might be worth
printing out what it's set to at the point where the skb->protocol
assignment above was removed.

I'm trying to wrap my head around all this right now but I don't yet see
how the code after the patch would not get skb->protocol correct.

johannes
