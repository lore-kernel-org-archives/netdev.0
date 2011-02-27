From: d@taht.net (Dave =?utf-8?Q?T=C3=A4ht?=)
Subject: Re: ANNOUNCE: debloat-testing kernel git tree
Date: Sun, 27 Feb 2011 09:25:56 -0700
Message-ID: <87tyfph2az.fsf@cruithne.co.teklibre.org>
References: <20110225222210.GA3618@tuxdriver.com>
	<AANLkTingkcc-dvs_8Nr0vYXdXvuDHEn6sz14tnHzLp8W@mail.gmail.com>
	<87fwr9jxya.fsf@cruithne.co.teklibre.org>
	<AANLkTinpG-xAC-VV-j7EBJB522+BqCyyFd_6N3KEr2Cf@mail.gmail.com>
	<8739n9ii7z.fsf@cruithne.co.teklibre.org>
	<AANLkTi=Cp7N4xqPyU6KWF6DOzFytxaA2BeoXhnhsZ6dp@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	bloat-devel-JXvr2/1DY2fm6VMwtOF2vx4hnT+Y9+D1@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: sedat.dilek-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <AANLkTi=Cp7N4xqPyU6KWF6DOzFytxaA2BeoXhnhsZ6dp-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
	(Sedat Dilek's message of "Sun, 27 Feb 2011 17:01:27 +0100")
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Sedat Dilek <sedat.dilek-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org> writes:

> On Sun, Feb 27, 2011 at 4:56 PM, Dave T=C3=A4ht <d@taht.net> wrote:
>> Sedat Dilek <sedat.dilek-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org> writes:
>>
>>> On Sun, Feb 27, 2011 at 4:31 PM, Dave T=C3=A4ht <d@taht.net> wrote:
>>>>
>>>> Sedat Dilek <sedat.dilek-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org> writes:
>>
>>> Are you planning debloat feature for 2.6.39?
>>
>> Depends on how many testers we get and what the results are.
>>
>> I feel the eBDP stuff will not be ready during this release cycle. S=
=46B
>> and CHOKe are in net-next, so, probably. Various driver patches -
>> particularly those that increase the available dynamic range via
>> ethtool, (e.g lowering the bottommost TX queue limit to, like, 4,
>> especially for home gateways) may make it out if people look harder =
into
>> the issue.
>
> OK, thanks for the explanations.
>
> Concerning "more drivers":
> What would I have to do to modify ath5k?
> I looked into the ath9k patch in debloat-testing GIT and it was to mo=
d
> some (TX/BUF) values only.

Yes, reducing your TX buffer size greatly is the first, best, and
easiest patch.

=46or wireless routers and cable home gateways especially, this researc=
h
shows that the total un-managed buffers in your system should be less
than 32.

http://www.cs.clemson.edu/~jmarty/papers/PID1154937.pdf

I found their data convincing, and there are dozens of other papers tha=
t
we are sorting out on the bufferbloat.net web site.

(PLEASE Note the key word there is un-managed)

0 would be the best value. :/

In the case of wireless, you also have retries to take into account.
I'd argue in those cases, that what I say above is that the number
should be FAR less than 32.

Now, whether there is a good compromise between throughput and latency
in that range in a DMA TX queue + TXQUEUE, remains to be seen.=20

> Not sure if ath9k is/was "well" prepared or only a good choice by the
> testers/committers as they own such a device.

My test network is mostly ath9k - the nanostation M5s and the WNDR5700
router described here:

http://www.bufferbloat.net/projects/bloat/wiki/Experiment_-_Bloated_LAG=
N_vs_debloated_WNDR5700

There are people looking into the ath6kl, but you're the first to step
up with the ath5k. :) Maybe the folk over at #ath6kl on irc can help.

The ath9k patch improves latency under load enormously - I can run voip
over it AND do big transfers and stream audio via samba... Which I
couldn't before - and DNS, ND, NTP, babel, etc behave much better, but
the currently hard coded nature of the TX queue limit does put an upper
limit on packet aggregation that the eBDP folk are trying to resolve
more generically.

In practice, at "normal" 180Mbit rates, with the new queue depth of 3, =
I
get most of the benefits of packet aggregation without the lag.

I do see higher packet loss than I would like, at present.

>
> - Sedat -

--=20
Dave Taht
http://nex-6.taht.net
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
