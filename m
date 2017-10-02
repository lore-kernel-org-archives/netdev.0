From: "Guedes, Andre" <andre.guedes@intel.com>
Subject: Re: [RFC net-next 0/5] TSN: Add qdisc-based config interfaces for
 traffic shapers
Date: Mon, 2 Oct 2017 23:06:47 +0000
Message-ID: <1506985606.13178.7.camel@intel.com>
References: <DM2PR0401MB1389A950EAC6FB54D4186B9C927E0@DM2PR0401MB1389.namprd04.prod.outlook.com>
         <CAEYbN3STY+7ZOodQLaP4MfbvwCovWsav52PXBmjHND7QOO=srg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=sha-1;
        protocol="application/x-pkcs7-signature"; boundary="=-OegElU58nhOHAPcnmvFq"
Cc: "Sanchez-Palencia, Jesus" <jesus.sanchez-palencia@intel.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "Gomes, Vinicius" <vinicius.gomes@intel.com>,
        "Briano, Ivan" <ivan.briano@intel.com>,
        "richardcochran@gmail.com" <richardcochran@gmail.com>,
        "henrik@austad.us" <henrik@austad.us>
To: "levipearson@gmail.com" <levipearson@gmail.com>,
        "rodney.cummings@ni.com" <rodney.cummings@ni.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:23307 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751104AbdJBXGx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 2 Oct 2017 19:06:53 -0400
In-Reply-To: <CAEYbN3STY+7ZOodQLaP4MfbvwCovWsav52PXBmjHND7QOO=srg@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--=-OegElU58nhOHAPcnmvFq
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Hi all,

On Mon, 2017-10-02 at 12:45 -0600, Levi Pearson wrote:
> Hi Rodney,
>=20
> Some archives seem to have threaded it, but I have CC'd the
> participants I saw in the original discussion thread since they may
> not otherwise notice it amongst the normal traffic.
>=20
> On Fri, Sep 29, 2017 at 2:44 PM, Rodney Cummings <rodney.cummings@ni.com>
> wrote:

[...]

> > 1. Question: From an 802.1 perspective, is this RFC intended to support
> > end-station (e.g. NIC in host), bridges (i.e. DSA), or both?
> >=20
> > This is very important to clarify, because the usage of this interface
> > will be very different for one or the other.
> >=20
> > For a bridge, the user code typically represents a remote management
> > protocol (e.g. SNMP, NETCONF, RESTCONF), and this interface is
> > expected to align with the specifications of 802.1Q clause 12,
> > which serves as the information model for management. Historically,
> > a standard kernel interface for management hasn't been viewed as
> > essential, but I suppose it wouldn't hurt.
>=20
> I don't think the proposal was meant to cover the case of non-local
> switch hardware, but in addition to dsa and switchdev switch ICs
> managed by embedded Linux-running SoCs, there are SoCs with embedded
> small port count switches or even plain multiple NICs with software
> bridging. Many of these embedded small port count switches have FQTSS
> hardware that could potentially be configured by the proposed cbs
> qdisc. This blurs the line somewhat between what is a "bridge" and
> what is an "end-station" in 802.1Q terminology, but nevertheless these
> devices exist, sometimes acting as an endpoint + a real bridge and
> sometimes as just a system with multiple network interfaces.

During the development of this proposal, we were most focused on end-statio=
n
use-cases. We considered some bridge use-cases as well just to verify that =
the
proposed design wouldn't be an issue if someone else goes for it.

We agree that the line between end-station and bridge can be a bit blurred =
(in
this case). Even though we designed this interface with end-station use-cas=
es
in mind, if the proposed infrastructure could be used as is in bridge use-
cases, good.

> > For an end station, the user code can be an implementation of SRP
> > (802.1Q clause 35), or it can be an application-specific
> > protocol (e.g. industrial fieldbus) that exchanges data according
> > to P802.1Qcc clause 46. Either way, the top-level user interface
> > is designed for individual streams, not queues and shapers. That
> > implies some translation code between that top-level interface
> > and this sort of kernel interface.

Yes, you're right. Our understanding is that the top-level interfaces shoul=
d be
implemented at user space as well as any stream management functionality. T=
he
idea here is to keep the kernel-side as simple as possible. The kernel hand=
les
hardware configuration (via Traffic Control interface) while the user space
handles TSN streams i.e. the kernel provides the mechanism and the user spa=
ce
provides the policy.

> > As a specific end-station example, for CBS, 802.1Q-2014 subclause
> > 34.6.1 requires "per-stream queues" in the Talker end-station.
> > I don't see 34.6.1 represented in the proposed RFC, but that's
> > okay... maybe per-stream queues are implemented in user code.
> > Nevertheless, if that is the assumption, I think we need to
> > clarify, especially in examples.
>=20
> You're correct that the FQTSS credit-based shaping algorithm requires
> per-stream shaping by Talker endpoints as well, but this is in
> addition to the per-class shaping provided by most hardware shaping
> implementations that I'm aware of in endpoint network hardware. I
> agree that we need to document the need to provide this, but it can
> definitely be built on top of the current proposal.
>=20
> I believe the per-stream shaping could be managed either by a user
> space application that manages all use of a streaming traffic class,
> or through an additional qdisc module that performs per-stream
> management on top of the proposed cbs qdisc, ensuring that the
> frames-per-observation interval aspect of each stream's reservation is
> obeyed. This becomes a fairly simple qdisc to implement on top of a
> per-traffic class shaper, and could even be implemented with the help
> of the timestamp that the SO_TXTIME proposal adds to skbuffs, but I
> think keeping the layers separate provides more flexibility to
> implementations and keeps management of various kinds of hardware
> offload support simpler as well.

Indeed, 'per-stream queue' is not covered in this RFC. For now, we expect i=
t to
be implemented in user code. We believe the proposed CBS qdisc could be
extended to support a full software-based implementation which would be use=
d to
implement 'per-stream queue' support. This functionality should be addresse=
d by
a separated series.

Anyways, we're about to send the v3 patchset implementing this proposal and
we'll make it clear.

> > 2. Suggestion: Do not assume that a time-aware (i.e. scheduled)
> > end-station will always use 802.1Qbv.
> >=20
> > For those who are subscribed to the 802.1 mailing list,
> > I'd suggest a read of draft P802.1Qcc/D1.6, subclause U.1
> > of Annex U. Subclause U.1 assumes that bridges in the network use
> > 802.1Qbv, and then it poses the question of what an end-station
> > Talker should do. If the end-station also uses 802.1Qbv,
> > and that end-station transmits multiple streams, 802.1Qbv is
> > a bad implementation. The reason is that the scheduling
> > (i.e. order in time) of each stream cannot be controlled, which
> > in turn means that the CNC (network manager) cannot optimize
> > the 802.1Qbv schedules in bridges. The preferred technique
> > is to use "per-stream scheduling" in each Talker, so that
> > the CNC can create an optimal schedules (i.e. best determinism).
> >=20
> > I'm aware of a small number of proprietary CNC implementations for
> > 802.1Qbv in bridges, and they are generally assuming per-stream
> > scheduling in end-stations (Talkers).
> >=20
> > The i210 NIC's LaunchTime can be used to implement per-stream
> > scheduling. I haven't looked at SO_TXTIME in detail, but it sounds
> > like per-stream scheduling. If so, then we already have the
> > fundamental building blocks for a complete implementation
> > of a time-aware end-station.
> >=20
> > If we answer the preceding question #1 as "end-station only",
> > I would recommend avoiding 802.1Qbv in this interface. There
> > isn't really anything wrong with it per-se, but it would lead
> > developers down the wrong path.
>=20
> In some situations, such as device nodes that each incorporate a small
> port count switch for the purpose of daisy-chaining a segment of the
> network, "end stations" must do a limited subset of local bridge
> management as well. I'm not sure how common this is going to be for
> industrial control applications, but I know there are audio and
> automotive applications built this way.
>=20
> One particular device I am working with now provides all network
> access through a DSA switch chip with hardware Qbv support in addtion
> to hardware Qav support. The SoC attached to it has no hardware timed
> launch (SO_TXTIME) support. In this case, although the proposed
> interface for Qbv is not *sufficient* to make a working time-aware end
> station, it does provide a usable building block to provide one. As
> with the credit-based shaping system, Talkers must provide an
> additional level of per-stream shaping as well, but this is largely
> (absent the jitter calculations, which are sort of a middle-level
> concern) independent of what sort of hardware offload of the
> scheduling is provided.
>=20
> Both Qbv windows and timed launch support do roughly the same thing;
> they *delay* the launch of a hardware-queued frame so it can egress at
> a precisely specified time, and at least with the i210 and Qbv, ensure
> that no other traffic will be in-progress when that time arrives. For
> either to be used effectively, the application still has to prepare
> the frame slightly ahead-of-time and thus must have the same level of
> time-awareness. This is, again, largely independent of what kind of
> hardware offloading support is provided and is also largely
> independent of the network stack itself. Neither queue window
> management nor SO_TXTIME help the application present its
> time-sensitive traffic at the right time; that's a matter to be worked
> out with the application taking advantage of PTP and the OS scheduler.
> Whether you rely on managed windows or hardware launch time to provide
> the precisely correct amount of delay beyond that is immaterial to the
> application. In the absence of SO_TXTIME offloading (or even with it,
> and in the presence of sufficient OS scheduling jitter), an additional
> layer may need to be provided to ensure different applications' frames
> are queued in the correct order for egress during the window. Again,
> this could be a purely user-space application multiplexer or a
> separate qdisc module.
>=20
> I wholeheartedly agree with you and Richard that we ought to
> eventually provide application-level APIs that don't require users to
> have deep knowledge of various 802.1Q intricacies. But I believe that
> the hardware offloading capability being provided now, and the variety
> of the way things are hooked up in real hardware, suggests that we
> ought to also build the support for the underlying protocols in layers
> so that we don't create unnecessary mismatches between offloading
> capability (which can be essential to overall network performance) and
> APIs, such that one configuration of offload support is privileged
> above others even when comparable scheduling accuracy could be
> provided by either.
>=20
> In any case, only the cbs qdisc has been included in the post-RFC
> patch cover page for its last couple of iterations, so there is plenty
> of time to discuss how time-aware shaping, preemption, etc. management
> should occur beyond the cbs and SO_TXTIME proposals.

Yes, based on the previous feedback about the Qbv offloading interface
('taprio'), we've decided to postpone its proposal until we have NICs
supporting Qbv and more realistic use-cases. The current proposal covers on=
ly
FQTSS.

Thanks for your feedback!

Best regards,

Andre
--=-OegElU58nhOHAPcnmvFq
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
SIb3DQEHATAcBgkqhkiG9w0BCQUxDxcNMTcxMDAyMjMwNjQ2WjAjBgkqhkiG9w0BCQQxFgQUFZ7t
lcHAYKmVdzkLSUnv5Af5fSUwDQYJKoZIhvcNAQEBBQAEggEAfd0etbaqad29029DxXwnZLHxOJF+
1JgNwvWAkiPExFfrPqYp9pqycZ+nYt2INb8lC1iBUye0rOgHRGZDRYAIzGDlKh7xHjRD2E6e1kav
3bgdVq3n9P/Fp7aEHE/2sDByrrf7/me4JUB0moyjPAzjX3YtuiAdD+nYcQbxFy3OuHm67WB+EJLG
zflL2D3kq5r3Ghc4p7dq6S3w/BcxqjvIE0rUJefMWpfWuri+RuN161aJPVRXyL2nQTQ/wCv7vqp+
kSYNOrfjG6iE1tk70wcusDoBiVyo3Y6rnrHVi6c/oJzyJ2C8NidiM+kLH4GgIJ7vETLzw/7Hazum
Oq8ZboHPxwAAAAAAAA==


--=-OegElU58nhOHAPcnmvFq--
