From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: skbuff truesize incorrect.
Date: Fri, 23 May 2014 11:48:29 +0200
Message-ID: <87r43k4yhe.fsf@nemi.mork.no>
References: <537E4AFD.20304@mentor.com>
	<1400792295.5367.174.camel@edumazet-glaptop2.roam.corp.google.com>
	<063D6719AE5E284EB5DD2968C1650D6D1724C490@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "'Eric Dumazet'" <eric.dumazet@gmail.com>,
	Jim Baxter <jim_baxter@mentor.com>,
	"linux-usb\@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"kamal\@canonical.com" <kamal@canonical.com>,
	"edumazet\@google.com" <edumazet@google.com>,
	"mszeredi\@suse.cz" <mszeredi@suse.cz>,
	"fw\@strlen.de" <fw@strlen.de>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1724C490@AcuExch.aculab.com>
	(David Laight's message of "Fri, 23 May 2014 08:52:13 +0000")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Laight <David.Laight@ACULAB.COM> writes:

> Since USB bulk data are terminated by a short fragment there is actua=
lly
> no need for the URB be long enough for the full message. Provided the
> URB are multiples of the USB message size (1k for USB 3) the message
> can be received into multiple URB - the driver just has to be willing
> to merge URB buffers (as well as split them) when generating the ethe=
rnet
> frames.
>
> What the driver needs to do us allocate URB with 2k (or 4k) buffers a=
nd
> only allocate the skb when processing the receive data.
> Unfortunately this is a major rework of usb_net.c

Yes, I believe this is the way to go as well.

I have been thinking about it in the context of the cdc_ncm driver.  On=
e
problem with the NCM protocol is that it will have to merge all the
buffers of a "NCM Transfer Block" (NTB) before it can process any part
of it.  The protocol puts no restrictions on the internal pointers in a
NTB, so there is no guarantee that we can start at the beginning and
work our way towards the end of it. The contained packets can be
interleaved with index(es) or the index can be at the end etc.

But this should still be possible to parse using a list of shorter
buffers to hold each NTB.

> Note that some of the usb ethernet drivers allocate large skb then
> lie about the truesize.

Hmm, which drivers are these?


Bj=C3=B8rn
