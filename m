From: Alexey Orishko <alexey.orishko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next 02/14] net: cdc_ncm: use device rx_max value if
 update failed
Date: Fri, 19 Oct 2012 12:01:39 +0200
Message-ID: <CAL_Kpj3QX_bpLh5yX5VXKaqq+TSO9+aVxt+1TrU9e1BamKdFkA@mail.gmail.com>
References: <1350592867-25651-1-git-send-email-bjorn@mork.no>
	<1350592867-25651-3-git-send-email-bjorn@mork.no>
	<3426241.1WN6uXHlgW@linux-lqwf.site>
	<87ehkvv3ej.fsf@nemi.mork.no>
	<CAL_Kpj0j9umyQBFFDVqWqEjH1057EjR0cZRcScdZG30E54=M0w@mail.gmail.com>
	<878vb3ufnx.fsf@nemi.mork.no>
	<871uguvmfy.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	Greg Suarez <gpsuarez2512-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"Fangxiaozhi (Franko)" <fangxiaozhi-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Aleksander Morgado <aleksander-bhGbAngMcJvQT0dZR+AlfA@public.gmane.org>
To: =?ISO-8859-1?Q?Bj=F8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <871uguvmfy.fsf-lbf33ChDnrE/G1V5fR+Y7Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 19, 2012 at 11:30 AM, Bj=F8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org> wrote:
> Bj=F8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org> writes:
>> Alexey Orishko <alexey.orishko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:
>>
> OK, I did some more experiments, and I am wondering if the real firmw=
are
> problem is in the MBIM descriptor.  It is
>
>       CDC MBIM:
>         bcdMBIMVersion       1.00
>         wMaxControlMessage   1536
>         bNumberFilters       16
>         bMaxFilterSize       40
>         wMaxSegmentSize      4096
>         bmNetworkCapabilities 0x20
>           8-byte ntb input size
>
>
> so we use the 8-byte version of USB_CDC_SET_NTB_INPUT_SIZE, which fai=
ls
> with -EPIPE.  But forcing the 4-byte version seems to work. Hmm, I al=
so
> see that the device returns 4 bytes in response to at
> USB_CDC_GET_NTB_INPUT_SIZE with an 8-byte buffer.  Maybe we can
> auto-quirk based on that?  I.e., if USB_CDC_GET_NTB_INPUT_SIZE return=
s
> only 4 bytes then we assume that the bmNetworkCapabilities flag is
> wrong.
>
> Is that acceptable?  Then it seems we are able to inform this device =
of
> the reduced buffer, and the other problems can be ignored.
>

Based on NCM errata, NCM functional descriptor: if Bit 5 is set, then
device can (must) handle 8-byte form of Set/GetNtbInputSize.
If they set a flag, but don't support the feature, hm.. is it a
prototype device or
commercially available one?

At least device must support Set request, but for GetNtbInputSize we
could happily
live without wNtbInMaxDatagrams (i.e. use 4 byte variant) on Linux.
Since we must anyway receive a complete NTB and making any number of sk=
b
buffers from received NTB is not a problem at all.

regards,
alexey
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
