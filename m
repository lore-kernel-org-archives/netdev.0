From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: Re: [PATCH net-next 10/11] qede: Add basic XDP support
Date: Mon, 28 Nov 2016 20:53:29 +0000
Message-ID: <BL2PR07MB2306004B997234AEEDE2F44B8D8A0@BL2PR07MB2306.namprd07.prod.outlook.com>
References: <1480258273-24973-1-git-send-email-Yuval.Mintz@cavium.com>
 <1480258273-24973-11-git-send-email-Yuval.Mintz@cavium.com>,<CALx6S36kiAiMeZoszx=5uBrUecwCodJx2tg3kL4HBk=4eVMSLg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam02on0069.outbound.protection.outlook.com ([104.47.36.69]:26763
        "EHLO NAM02-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751537AbcK1Uxb (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 28 Nov 2016 15:53:31 -0500
In-Reply-To: <CALx6S36kiAiMeZoszx=5uBrUecwCodJx2tg3kL4HBk=4eVMSLg@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > +=A0 =A0 =A0 =A0if (act =3D=3D XDP_PASS)
> > +=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return true;
> > +
> > +=A0 =A0 =A0 =A0/* Count number of packets not to be passed to stack */
> > +=A0 =A0 =A0 =A0rxq->xdp_no_pass++;
> > +
> > +=A0 =A0 =A0 =A0switch (act) {
> > +=A0 =A0 =A0 =A0default:
> > +=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0bpf_warn_invalid_xdp_action(act);

> XDP_TX is a valid action and in fact some drivers already support that.
> Given that this isn't the first instance of driver not supporting XDP_TX
> I think we need to clear define what means. Personally, I think that we
> shouldn't allow a program to load that  returns XDP_TX but driver does
> not support it. I believe Jesper might be looking into capabilities
> support for XDP to handle that. For the purposes of this patch I'd sugges=
t
> having an XDP_TX case and warn user that an unsupported action
> as opposed to invalid  one was returned.

Patch #11 does add XDP_TX support.
Adding an explicit case with a warning to be removed in the next patch
sounds like a waste to me. But if you think 'future generations' would
benefit from it, sure.
=A0
> > +=A0 =A0 =A0 =A0case XDP_ABORTED:
> > +=A0 =A0 =A0 =A0case XDP_DROP:
