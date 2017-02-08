From: Denny Page <dennypage@me.com>
Subject: Re: Extending socket timestamping API for NTP
Date: Tue, 07 Feb 2017 17:18:36 -0800
Message-ID: <D6B1A73A-BF2E-4EEF-A198-2B52857381D9@me.com>
References: <20170207140144.GA11233@localhost>
Mime-Version: 1.0 (Mac OS X Mail 10.2 \(3259\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, Richard Cochran <richardcochran@gmail.com>,
        Jiri Benc <jbenc@redhat.com>,
        "Keller, Jacob E" <jacob.e.keller@intel.com>,
        Willem de Bruijn <willemb@google.com>
To: Miroslav Lichvar <mlichvar@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from st11p06im-asmtp002.me.com ([17.172.125.150]:46288 "EHLO
        st11p06im-asmtp002.me.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751959AbdBHGUv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 01:20:51 -0500
Received: from process-dkim-sign-daemon.st11p06im-asmtp002.me.com by
 st11p06im-asmtp002.me.com
 (Oracle Communications Messaging Server 7.0.5.38.0 64bit (built Feb 26 2016))
 id <0OL1005007HUOS00@st11p06im-asmtp002.me.com> for netdev@vger.kernel.org;
 Wed, 08 Feb 2017 01:18:39 +0000 (GMT)
In-reply-to: <20170207140144.GA11233@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Feb 07, 2017, at 06:01, Miroslav Lichvar <mlichvar@redhat.com> =
wrote:
>=20
> 1) new rx_filter for NTP
>=20
>   Some NICs can't timestamp all received packets and are currently
>   unusable for NTP with HW timestamping. The new filter would allow
>   NTP support in new NICs and adding support to existing NICs with
>   firmware/driver updates. The filter would apply to IPv4 and IPv6
>   UDP packets received from or sent to the port number 123.
>=20

I think this is a good idea. Even if the hardware doesn=E2=80=99t =
support it, the filtering could be done in the kernel. Save a huge =
number of context switches.



> 4) allow sockets to use both SW and HW TX timestamping at the same =
time
>=20
>   When using a socket which is not bound to a specific interface, it
>   would be nice to get transmit SW timestamps when HW timestamps are
>   missing. I suspect it's difficult to predict if a HW timestamp will
>   be available. Maybe it would be acceptable to get from the error
>   queue two messages per transmission if the interface supports both
>   SW and HW timestamping?
>=20

Highly agreed. The current interface pretty much forces a socket per =
physical interface, which should not be necessary.


> 5) new SO_TIMESTAMPING options to get transposed RX timestamps
>=20
>   PTP uses preamble RX timestamps, but NTP works with trailer RX
>   timestamps. This means NTP implementations currently need to
>   transpose HW RX timestamps. The calculation requires the link speed
>   and the length of the packet at layer 2. It seems this can be
>   reliably done only using raw sockets. It would be very nice if the
>   kernel could tranpose the timestamps automatically.
>=20
>   The existing SOF_TIMESTAMPING_RX_HARDWARE flag could be aliased to
>   SOF_TIMESTAMPING_RX_HARDWARE_PREAMBLE and the new flag could be
>   SOF_TIMESTAMPING_RX_HARDWARE_TRAILER.
>=20
>   PTP has a similar problem with SW RX timestamps, which are closer
>   to the trailer timestamps rather than preamble timestamps. A new
>   SOF_TIMESTAMPING_RX_SOFTWARE_PREAMBLE flag could be added for PTP
>   implementations to get transposed timestamps in order to improve
>   accuracy.
>=20

Also highly agreed.

Denny
