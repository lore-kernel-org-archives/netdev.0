From: Denny Page <dennypage@me.com>
Subject: Re: Extending socket timestamping API for NTP
Date: Tue, 07 Feb 2017 17:52:52 -0800
Message-ID: <BBA8C11E-44DF-4693-957F-0354BEC75FC3@me.com>
References: <20170207140144.GA11233@localhost>
 <02874ECE860811409154E81DA85FBB5857D6DC87@ORSMSX115.amr.corp.intel.com>
Mime-Version: 1.0 (Mac OS X Mail 10.2 \(3259\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: Miroslav Lichvar <mlichvar@redhat.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Richard Cochran <richardcochran@gmail.com>,
        Jiri Benc <jbenc@redhat.com>,
        Willem de Bruijn <willemb@google.com>
To: "Keller, Jacob E" <jacob.e.keller@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from st11p06im-asmtp001.me.com ([17.172.125.149]:60808 "EHLO
        st11p06im-asmtp001.me.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932644AbdBHBxU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 20:53:20 -0500
Received: from process-dkim-sign-daemon.st11p06im-asmtp001.me.com by
 st11p06im-asmtp001.me.com
 (Oracle Communications Messaging Server 7.0.5.38.0 64bit (built Feb 26 2016))
 id <0OL100R0095M4500@st11p06im-asmtp001.me.com> for netdev@vger.kernel.org;
 Wed, 08 Feb 2017 01:52:55 +0000 (GMT)
In-reply-to: <02874ECE860811409154E81DA85FBB5857D6DC87@ORSMSX115.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Resend without rich text]

> On Feb 07, 2017, at 09:45, Keller, Jacob E <jacob.e.keller@intel.com> =
wrote:
>=20
> The main problem here is that most hardware that *can't* timestamp all =
packets is pretty limited to timestamping only PTP frames.


Most, but not all. The TI DP83630 doesn=E2=80=99t support timestamping =
for all packets, but it does support either PTP or NTP:

=3D=3D=3D
2.3.2.3 NTP Packet Timestamp
The DP83630 may be programmed to timestamp NTP packets instead of PTP =
packets. This operation is enabled by setting the NTP_TS_EN control in =
the PTP_TXCFG0 register. When configured for NTP timestamps, the DP83630 =
will timestamp packets with the NTP UDP port number rather than the PTP =
port number (note that the device cannot be configured to timestamp both =
PTP and NTP packets). One-Step operation is not supported for NTP =
timestamps, so transmit timestamps cannot be inserted directly into =
outgoing NTP packets. Timestamp insertion is available for receive =
timestamps but must use a single, fixed location.=20
=3D=3D=3D

Right now, there is no API to signal to the driver that NTP timestamping =
is desired.

Even if the hardware does not directly support filtering, it can be =
implemented in the driver.

Denny=
