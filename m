From: Kevin Zhu <Mingying.Zhu-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org>
Subject: Re: Is this 32-bit NCM?
Date: Mon, 1 Dec 2014 02:31:10 +0000
Message-ID: <547BD2EA.5060003@audiocodes.com>
References: <alpine.LNX.2.03.1411262250160.4356@gmail.com>
 <87ppc957h1.fsf@nemi.mork.no> <alpine.LNX.2.03.1411271037050.9464@gmail.com>
 <874mtl55ar.fsf@nemi.mork.no> <alpine.LNX.2.03.1411301931280.2605@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eli Britstein <Eli.Britstein-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org>,
	"youtux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <youtux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"alexxst-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <alexxst-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"Midge Shaojun Tan" <ShaojunMidge.Tan-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org>
To: Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	=?iso-8859-15?Q?Bj=F8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <alpine.LNX.2.03.1411301931280.2605-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Content-Language: en-US
Content-ID: <616C71DB4571DB469652863ABF52B124-NhzUejbdEhGcE4WynfumptQqCkab/8FMAL8bYrjMMd8@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Sorry for the late reply.

I tried to calculate the offset as what windows did, but it did not hel=
p.

Regards,
Kevin

On 12/01/2014 02:36 AM, Enrico Mioso wrote:
> Thank you Bjorn for the help and suggestions.
> These are parameters that the driver ends up choosing:
> /sys/class/net/wwan0/cdc_ncm/bmNtbFormatsSupported:0x0003
> /sys/class/net/wwan0/cdc_ncm/dwNtbInMaxSize:131072
> /sys/class/net/wwan0/cdc_ncm/dwNtbOutMaxSize:16384
> /sys/class/net/wwan0/cdc_ncm/min_tx_pkt:14848
> /sys/class/net/wwan0/cdc_ncm/rx_max:16384
> /sys/class/net/wwan0/cdc_ncm/tx_max:16384
> /sys/class/net/wwan0/cdc_ncm/tx_timer_usecs:400
> /sys/class/net/wwan0/cdc_ncm/wNdpInAlignment:4
> /sys/class/net/wwan0/cdc_ncm/wNdpInDivisor:4
> /sys/class/net/wwan0/cdc_ncm/wNdpInPayloadRemainder:2
> /sys/class/net/wwan0/cdc_ncm/wNdpOutAlignment:4
> /sys/class/net/wwan0/cdc_ncm/wNdpOutDivisor:4
> /sys/class/net/wwan0/cdc_ncm/wNdpOutPayloadRemainder:2
> /sys/class/net/wwan0/cdc_ncm/wNtbOutMaxDatagrams:0
>
> Sorry if I did not report them before. If I missed someone in CC plea=
se add it
> guys.
> Kevin - after you discovered that the device might handle the offset =
in a
> different way, have you tried this approach?
>
>
> On Thu, 27 Nov 2014, Bj=F8rn Mork wrote:
>
> =3D=3DDate: Thu, 27 Nov 2014 11:03:24
> =3D=3DFrom: Bj=F8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
> =3D=3DTo: Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> =3D=3DCc: youtux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, alexxst-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-usb-u79uwXL29TasMV2rI37PzA@public.gmane.org=
org,
> =3D=3D    netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> =3D=3DSubject: Re: Is this 32-bit NCM?
> =3D=3D
> =3D=3DEnrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:
> =3D=3D
> =3D=3D> Ok - we can arrive to some ocnclusions regarding the E3272.
> =3D=3D> First of all - the modem seems buggy enough to not be able to=
 handle requests
> =3D=3D> for different formats. You need to unplug and re-plug it, but=
 this is onlyan
> =3D=3D> impression and is reasonable.
> =3D=3D>
> =3D=3D> Then - the modem will accept to ndisdup the connection with
> =3D=3D> at^ndisdup=3D1,1,"internet"
> =3D=3D> but - if we use huawei_cdc_ncm + cdc_ncm we have no flow hand=
ling messages and
> =3D=3D> the modem stops here.
> =3D=3D> If we use the cdc_ncm 32-bit driver (modified) we get lotfs o=
f
> =3D=3D> ^dsflorpt
> =3D=3D> that's how it should be.
> =3D=3D> So I think we can say that something is changing.
> =3D=3D> Then there's the alignment problem you mentioned in your prev=
ious reply. And
> =3D=3D> this is hard to solve.
> =3D=3D> could you try to help me understand where the problem is?
> =3D=3D> I feel like we are very close to the solution but something i=
sn't working.
> =3D=3D> Or might be just try to change the 16 bit driver?
> =3D=3D
> =3D=3DIf you use a recent version of the driver as a basis, then you =
get the
> =3D=3DCDC NCM NTB parameters in sysfs (if not, then you need to enabl=
e
> =3D=3Ddebugging and look in the log for these values).  For example:
> =3D=3D
> =3D=3Dbjorn@nemi:~$ grep . /sys/class/net/wwan0/cdc_ncm/*
> =3D=3D/sys/class/net/wwan0/cdc_ncm/bmNtbFormatsSupported:0x0001
> =3D=3D/sys/class/net/wwan0/cdc_ncm/dwNtbInMaxSize:15360
> =3D=3D/sys/class/net/wwan0/cdc_ncm/dwNtbOutMaxSize:15360
> =3D=3D/sys/class/net/wwan0/cdc_ncm/min_tx_pkt:13824
> =3D=3D/sys/class/net/wwan0/cdc_ncm/rx_max:15360
> =3D=3D/sys/class/net/wwan0/cdc_ncm/tx_max:15360
> =3D=3D/sys/class/net/wwan0/cdc_ncm/tx_timer_usecs:400
> =3D=3D/sys/class/net/wwan0/cdc_ncm/wNdpInAlignment:4
> =3D=3D/sys/class/net/wwan0/cdc_ncm/wNdpInDivisor:1
> =3D=3D/sys/class/net/wwan0/cdc_ncm/wNdpInPayloadRemainder:0
> =3D=3D/sys/class/net/wwan0/cdc_ncm/wNdpOutAlignment:4
> =3D=3D/sys/class/net/wwan0/cdc_ncm/wNdpOutDivisor:32
> =3D=3D/sys/class/net/wwan0/cdc_ncm/wNdpOutPayloadRemainder:0
> =3D=3D/sys/class/net/wwan0/cdc_ncm/wNtbOutMaxDatagrams:32
> =3D=3D
> =3D=3D
> =3D=3DThe possible problem I am thinking of is proper handling of the
> =3D=3DwNdp*PayloadRemainder values. See section 3.3.4 "NCM Ethernet F=
rame
> =3D=3DAlignment" in the spec.  Which is confusing as hell, but if I u=
nderstand
> =3D=3Dit correctly then we are supposed to align the start of the IP =
packets
> =3D=3D(the "payload", _not_ the ethernet frame) to a whole wNdp*Divis=
or number
> =3D=3Das long as the wNdp*PayloadRemainder is 0.
> =3D=3D
> =3D=3D
> =3D=3DBj=F8rn
> =3D=3D
This email and any files transmitted with it are confidential material.=
 They are intended solely for the use of the designated individual or e=
ntity to whom they are addressed. If the reader of this message is not =
the intended recipient, you are hereby notified that any dissemination,=
 use, distribution or copying of this communication is strictly prohibi=
ted and may be unlawful.

If you have received this email in error please immediately notify the =
sender and delete or destroy any copy of this message
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
