From: Daniel Drake <dsd-2X9k7bc8m7Mdnm+yROfE0A@public.gmane.org>
Subject: Re: Frequent spurious tx_timeouts for libertas
Date: Mon, 2 May 2011 20:59:04 +0100
Message-ID: <BANLkTi=FT4v=Jvv5bQpUX15R87kPudKq=Q@mail.gmail.com>
References: <BANLkTintnaEj0DDjwQJjc4wpuz-c_QOGyg@mail.gmail.com>
	<1304303082.2833.159.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, libertas-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1304303082.2833.159.camel@localhost>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 2 May 2011 03:24, Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org> wrote:
>> Also, while looking at this code, I spotted a bug in dev_watchdog():
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* old=
 device drivers set dev->trans_start
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 trans_st=
art =3D txq->trans_start ? : dev->trans_start;
>>
>> i.e. it is trying to figure out whether to read trans_start from txq
>> or dev. In both cases, trans_start is updated based on the value of
>> jiffies, which will occasionally be 0 (as it wraps around). Therefor=
e
>> this line of code will occasionally make the wrong decision.
>
> No, I don't think so.
>
> If only dev->trans_start is being updated then the watchdog reads tha=
t.
> If both txq->trans_start and dev->trans_start are being updated then =
it
> doesn't matter much which the watchdog reads.
> If only txq->trans_start is being updated then dev->trans_start is
> always set to 0, so when txq->trans_start is 0 the watchdog still get=
s
> 0.

dev->trans_start is unconditionally initialized by dev_activate() in
sch_generic.c:

	if (need_watchdog) {
		dev->trans_start =3D jiffies;
		dev_watchdog_up(dev);
	}

so it is (usually) not 0.

Thanks for your input on the tx timeout issue, now that I understand
it better I think the right plan of action is to remove it from
libertas entirely, I'll CC you on the patch.

Daniel
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
