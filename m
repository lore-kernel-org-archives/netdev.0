From: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH v2 2/3] net: usb: cdc_enc: New driver exposing USB CDC encapsulated protocols
Date: Sun, 15 Jan 2012 21:33:38 +0100
Message-ID: <201201152133.38183.oliver@neukum.org>
References: <cover.1326607234.git.bjorn@mork.no> <87lip9dp11.fsf@nemi.mork.no> <87ehv0eoah.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Thomas =?utf-8?q?Sch=C3=A4fer?= <tschaefer-zqRNUXuvxA0b1SvskN2V4Q@public.gmane.org>
To: =?utf-8?q?Bj=C3=B8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <87ehv0eoah.fsf-lbf33ChDnrE/G1V5fR+Y7Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Am Sonntag, 15. Januar 2012, 20:52:38 schrieb Bj=C3=B8rn Mork:

> There is one fundamental design issue which worries me though: cdc-wd=
m
> doesn't support multiple simultaneous readers/writers.  This is sort =
of
> a blocker for my use case, as I will need to keep a reader/writer for
> the driver internal wwan management at all times.  So two simultaneou=
s
> clients are necessary to actually have something available for
> userspace at all.

What exactly do you need? The ability to write while another task is re=
ading?

> Are there any reasons for this choice, and do you think it's feasible

Easier to get the locking right.

> changing it without destroying the advantage of the well tested code?=
  I
> seem to remember that cdc-wdm allowed simultaneous reading/writing in
> the past, but this changed somewhere between 2.6.32 and 3.0. I have a=
n

There might have been a locking bug which was easy to fix this way.

> Ericsson modem with two such AT command speaking interfaces, and I us=
e a
> simple shell script to configure it.  At one point I had to switch fr=
om
> using /dev/cdc-wdm0 to /dev/ttyACM0 because the former started hangin=
g
> on constructs like this:
>=20
>     while read x; do
>     case "$x" in
>          foo)
>               echo -e "AT+bar\r" >/dev/cdc-wdm0
>               ;;
>          ...
>         esac
>     done </dev/cdc-wdm0
>              =20
>=20
> This used to work with 2.6.32, but that might have been just pure luc=
k?
> Anyway, that change really made cdc-wdm much less usable for me, and
> that sort of proves that supporting simultaneous read/write would be =
an
> improvement even for the existing supported devices.

Then feel free to add it, just beware of deadlocks.

> And then there are a couple of minor issues which I believe needs
> sorting out.  If I understand the WDM spec correctly (without botheri=
ng
> to actually read if, of course), then it only defines the interface b=
ut
> not the protocol.  Exactly like the embedded CDC Ethernet command
> interface.  So I have the Ericsson modem which which speaks an AT
> command protocol, of course with a number of vendor specific AT comma=
nds
> included.  And then I have the Huawei modem which speaks QMI.  Just
> mapping these to a number of /dev/cdc-wdmX interfaces isn't going to
> help user applications much.  They need to be told *what* protocol to
> use on the character device.  And the driver should know this, either=
 by
> detection or maybe best: vid/pid based tables and sane fallbacks.

I see.

> Do you think it would be possible to add that (or similar meta data) =
to
> the cdc-wdmX devices?  Maybe letting it default to "AT"?  Or "unknown=
"?
> Any thoughts on this?  How do actual user applications deal with this=
?

Well, you need a pointer at the correct "control" interface anyway. Wou=
ldn't you better
put the "protocol" attribute there?

	Regards
		Oliver
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
