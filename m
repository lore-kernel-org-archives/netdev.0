From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: linux-next: Tree for Aug 6 [ wireless | iwlwifi | mac80211 ? ]
Date: Tue, 06 Aug 2013 23:58:42 +0200
Message-ID: <1375826322.10459.6.camel@jlt4.sipsolutions.net>
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
	 (sfid-20130806_234032_528772_3836D785) <1375825538.10459.1.camel@jlt4.sipsolutions.net>
	 (sfid-20130806_234555_992441_64BE9CEF)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	wireless <linux-wireless@vger.kernel.org>, netdev@vger.kernel.org
To: sedat.dilek@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:56685 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754940Ab3HFV6w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Aug 2013 17:58:52 -0400
In-Reply-To: <1375825538.10459.1.camel@jlt4.sipsolutions.net> (sfid-20130806_234555_992441_64BE9CEF)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-08-06 at 23:45 +0200, Johannes Berg wrote:

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

Actually, I think that's not it, but the code now behaves totally
differently?

Say this is the frame data with two points marked:

(1)                   (2)
 | dst | src | ethtype | ... |

As I understand it (in my admittedly rather tired state), previously we
had

skb_network_header() == (1)
skb_mac_header()     == (1)
skb->data            == (1)

After calling eth_type_trans(), we get

skb_network_header() == (1)
skb_mac_header()     == (1)
skb->data            == (2)

I think? Maybe I'm totally confused though.

johannes
