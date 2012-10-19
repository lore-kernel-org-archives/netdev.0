From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: Re: [PATCH net-next 02/14] net: cdc_ncm: use device rx_max value if update failed
Date: Fri, 19 Oct 2012 14:18:11 +0200
Message-ID: <878vb2u03g.fsf@nemi.mork.no>
References: <1350592867-25651-1-git-send-email-bjorn@mork.no>
	<1350592867-25651-3-git-send-email-bjorn@mork.no>
	<3426241.1WN6uXHlgW@linux-lqwf.site> <87ehkvv3ej.fsf@nemi.mork.no>
	<CAL_Kpj0j9umyQBFFDVqWqEjH1057EjR0cZRcScdZG30E54=M0w@mail.gmail.com>
	<878vb3ufnx.fsf@nemi.mork.no> <871uguvmfy.fsf@nemi.mork.no>
	<CAL_Kpj3QX_bpLh5yX5VXKaqq+TSO9+aVxt+1TrU9e1BamKdFkA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	Greg Suarez <gpsuarez2512-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"Fangxiaozhi \(Franko\)" <fangxiaozhi-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Aleksander Morgado <aleksander-bhGbAngMcJvQT0dZR+AlfA@public.gmane.org>
To: Alexey Orishko <alexey.orishko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAL_Kpj3QX_bpLh5yX5VXKaqq+TSO9+aVxt+1TrU9e1BamKdFkA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
	(Alexey Orishko's message of "Fri, 19 Oct 2012 12:01:39 +0200")
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Alexey Orishko <alexey.orishko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:

> Based on NCM errata, NCM functional descriptor: if Bit 5 is set, then
> device can (must) handle 8-byte form of Set/GetNtbInputSize.
> If they set a flag, but don't support the feature, hm.. is it a
> prototype device or
> commercially available one?
>
> At least device must support Set request, but for GetNtbInputSize we
> could happily
> live without wNtbInMaxDatagrams (i.e. use 4 byte variant) on Linux.
> Since we must anyway receive a complete NTB and making any number of =
skb
> buffers from received NTB is not a problem at all.

OK, I may have misunderstood you here.  Quoting the errata text:

<quote>
  If bit D5 is set in the bmNetworkCapabilities field of function=E2=80=
=99s NCM
  Functional Descriptor, the host may set wLength either to 4 or to
  8. If wLength is 4, the function shall assume that wNtbInMaxDatagrams
  is to be set to zero. If wLength is 8, then the function shall use th=
e
  provided value as the limit. The function shall return an error
  response (a STALL PID) if wLength is set to any other value.
</quote>

So the 4 byte variant is always supported and we might as well just use
it unconditionally because we don't set, or need to set, the
wNtbInMaxDatagrams.

Is that right?  It will simplify the code even more without any loss of
functionality, except for the possibility of failing on some other bugg=
y
device not supporting the 4 byte variant...


Bj=C3=B8rn
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
