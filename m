From: "Guedes, Andre" <andre.guedes@intel.com>
Subject: Re: [next-queue PATCH 2/3] net/sched: Introduce Credit Based Shaper
 (CBS) qdisc
Date: Wed, 27 Sep 2017 23:11:01 +0000
Message-ID: <1506553861.4536.2.camel@intel.com>
References: <20170926233916.11774-1-vinicius.gomes@intel.com>
         <20170926233916.11774-3-vinicius.gomes@intel.com>
         <CAM_iQpVrz+e=TYHYqaYyUWRP528GSZXx8EnN1yPhZK8eLvP4Yw@mail.gmail.com>
         <87lgkzg7xv.fsf@intel.com> <4b0e1610-c9df-191d-496e-4be04c785d2f@intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=sha-1;
        protocol="application/x-pkcs7-signature"; boundary="=-pA1c75+KfcOBsKRXHQ6r"
Cc: "jiri@resnulli.us" <jiri@resnulli.us>,
        "jhs@mojatatu.com" <jhs@mojatatu.com>,
        "Ong, Boon Leong" <boon.leong.ong@intel.com>,
        "richardcochran@gmail.com" <richardcochran@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "henrik@austad.us" <henrik@austad.us>,
        "Briano, Ivan" <ivan.briano@intel.com>,
        "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>
To: "Sanchez-Palencia, Jesus" <jesus.sanchez-palencia@intel.com>,
        "Gomes, Vinicius" <vinicius.gomes@intel.com>,
        "xiyou.wangcong@gmail.com" <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:46831 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752447AbdI0XLH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 27 Sep 2017 19:11:07 -0400
In-Reply-To: <4b0e1610-c9df-191d-496e-4be04c785d2f@intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--=-pA1c75+KfcOBsKRXHQ6r
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2017-09-27 at 15:57 -0700, Jesus Sanchez-Palencia wrote:
> Hi,
>=20
>=20
> On 09/27/2017 02:14 PM, Vinicius Costa Gomes wrote:
> > Hi,
> >=20
> > Cong Wang <xiyou.wangcong@gmail.com> writes:
> >=20
> > > On Tue, Sep 26, 2017 at 4:39 PM, Vinicius Costa Gomes
> > > <vinicius.gomes@intel.com> wrote:
> > > > +static int cbs_init(struct Qdisc *sch, struct nlattr *opt)
> > > > +{
> > > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0struct cbs_sched_data *q=
 =3D qdisc_priv(sch);
> > > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0struct net_device *dev =
=3D qdisc_dev(sch);
> > > > +
> > > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0if (!opt)
> > > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0return -EINVAL;
> > > > +
> > > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0/* FIXME: this means tha=
t we can only install this qdisc
> > > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0* "under" mqprio. =
Do we need a more generic way to retrieve
> > > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0* the queue, or do=
 we pass the netdev_queue to the driver?
> > > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0*/
> > > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0q->queue =3D TC_H_MIN(sc=
h->parent) - 1 - netdev_get_num_tc(dev);
> > > > +
> > > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0return cbs_change(sch, o=
pt);
> > > > +}
> > >=20
> > > Yeah it is ugly to assume its parent is mqprio, at least you should
> > > error out if it is not the case.
> >=20
> > Will add an error for this, for now.
> >=20
> > >=20
> > > I am not sure how we can solve this elegantly, perhaps you should
> > > extend mqprio rather than add a new one?
> >=20
> > Is the alternative hinted in the FIXME worse? Instead of passing the
> > index of the hardware queue to the driver we pass the pointer to a
> > netdev_queue to the driver and it "discovers" the HW queue from that.

I don't see why we should move the queue index "discovery" into the driver.=
 The
driver layer should be dead simple and getting the queue index from the upp=
er
layer (qdisc) looks right to me.

> What if we keep passing the index, but calculate it from the netdev_queue
> pointer instead?
>=20
> i.e.:=C2=A0=C2=A0q->queue =3D sch->dev_queue - netdev_get_tx_queue(dev, 0=
);
>=20
> At least it wouldn't rely on the root qdisc being of any specific type.

+1

- Andre
--=-pA1c75+KfcOBsKRXHQ6r
Content-Type: application/x-pkcs7-signature; name="smime.p7s"
Content-Disposition: attachment; filename="smime.p7s"
Content-Transfer-Encoding: base64

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
UizwODL0ejWFvIsCUeYSP2hojKPWo+Rd3xqVimkMF4BtboMY1QcGgHrUz+39T0ykiwIDAQABo4IC
LzCCAiswHQYDVR0OBBYEFGx9NuU31zGSN+jD/sIvs5oY7S+3MB8GA1UdIwQYMBaAFB5pKrTcKP5H
GE4hCz+8rBEv8Jj1MGUGA1UdHwReMFwwWqBYoFaGVGh0dHA6Ly93d3cuaW50ZWwuY29tL3JlcG9z
aXRvcnkvQ1JML0ludGVsJTIwRXh0ZXJuYWwlMjBCYXNpYyUyMElzc3VpbmclMjBDQSUyMDRBLmNy
bDCBnwYIKwYBBQUHAQEEgZIwgY8waQYIKwYBBQUHMAKGXWh0dHA6Ly93d3cuaW50ZWwuY29tL3Jl
cG9zaXRvcnkvY2VydGlmaWNhdGVzL0ludGVsJTIwRXh0ZXJuYWwlMjBCYXNpYyUyMElzc3Vpbmcl
MjBDQSUyMDRBLmNydDAiBggrBgEFBQcwAYYWaHR0cDovL29jc3AuaW50ZWwuY29tLzALBgNVHQ8E
BAMCB4AwPAYJKwYBBAGCNxUHBC8wLQYlKwYBBAGCNxUIhsOMdYSZ5VGD/YEohY6fU4KRwAlngd69
OZXwQwIBZAIBCTAfBgNVHSUEGDAWBggrBgEFBQcDBAYKKwYBBAGCNwoDDDApBgkrBgEEAYI3FQoE
HDAaMAoGCCsGAQUFBwMEMAwGCisGAQQBgjcKAwwwSQYDVR0RBEIwQKAmBgorBgEEAYI3FAIDoBgM
FmFuZHJlLmd1ZWRlc0BpbnRlbC5jb22BFmFuZHJlLmd1ZWRlc0BpbnRlbC5jb20wDQYJKoZIhvcN
AQEFBQADggEBAE+EXag/N5PkW1uXsayWx3r4MzYFcznK3N1UG/6qR+UUB/PD4tbgU5M+IoP9gOp+
hzTOxM1PWxhyD24upEzuinkJ3BknENUeFZEaWnYQi306SMzJP3CzEiWogQ2/+JJXYb2vvQjeKEaq
mFdqshHJ7uFxdjmCYHlxmZte2oBC6DbaKeHcHyFxe0xxuaTwOQE3OoJNVcxpN2xK9rbnoe2a/oeg
LLn91PvxSNgjH0QC/TeY5kf5Pif4RAKi9ZsI6OwPhEpFhZbTJISCwmgdGcK/mVGyVtBaXciOboVJ
EwrCLsa+eAhbGn4F4MwTumo6oyzZa2SkenXS5M7chmcL0FvJ6F4xggIXMIICEwIBATCBkDB5MQsw
CQYDVQQGEwJVUzELMAkGA1UECBMCQ0ExFDASBgNVBAcTC1NhbnRhIENsYXJhMRowGAYDVQQKExFJ
bnRlbCBDb3Jwb3JhdGlvbjErMCkGA1UEAxMiSW50ZWwgRXh0ZXJuYWwgQmFzaWMgSXNzdWluZyBD
QSA0QQITMwAAi3Vjd570fy3HwgAAAACLdTAJBgUrDgMCGgUAoF0wGAYJKoZIhvcNAQkDMQsGCSqG
SIb3DQEHATAcBgkqhkiG9w0BCQUxDxcNMTcwOTI3MjMxMTAxWjAjBgkqhkiG9w0BCQQxFgQU7L8d
txkb6HFKMlxF3LswF0FGiTQwDQYJKoZIhvcNAQEBBQAEggEApdcNMPBF/zlRO3oox8/pOAjcMK/q
kdKYaT70Kl0Aw4bQIRtOWwxPpSp1RB3SsipvpojZ/OxUkMm5hs9e0qDx1UzxN6ZW11q3l8A9XBOk
ZSvlPhWo/v+J2f19cRNz0LLCkixY9M8lB6hGhgk6srJs07XSozOeaoLoMppvgNLDBz4v1JTydfh2
S1q2vT9CI3M5j5rvrgQRz4S9eCyQALOzjKjgXK3zWn6AI/XBpfQGe+DoMZKYU5ONS/CwkUgD9lnk
pWZnA0MQuk2feZLwOhPLFUXV0WO7hAvdgYJcNxjl2o4qsaZCmjMhx5Dq9gymDSTuUqnhif4I3xKm
xBLFa6JAzgAAAAAAAA==


--=-pA1c75+KfcOBsKRXHQ6r--
