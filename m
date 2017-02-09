From: Denny Page <dennypage@me.com>
Subject: Re: Extending socket timestamping API for NTP
Date: Thu, 09 Feb 2017 12:25:43 -0800
Message-ID: <C3BAD228-118B-4810-9FA0-6007EEE62368@me.com>
References: <20170207140144.GA11233@localhost>
 <2DAAE40C-75B6-48F6-B57F-1C72086929B9@me.com>
Mime-Version: 1.0 (Mac OS X Mail 10.2 \(3259\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, Richard Cochran <richardcochran@gmail.com>,
        Jiri Benc <jbenc@redhat.com>,
        "Keller, Jacob E" <jacob.e.keller@intel.com>,
        Willem de Bruijn <willemb@google.com>
To: Miroslav Lichvar <mlichvar@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from st11p06im-asmtp001.me.com ([17.172.125.149]:48353 "EHLO
        st11p06im-asmtp001.me.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753483AbdBIV0s (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 16:26:48 -0500
Received: from process-dkim-sign-daemon.st11p06im-asmtp001.me.com by
 st11p06im-asmtp001.me.com
 (Oracle Communications Messaging Server 7.0.5.38.0 64bit (built Feb 26 2016))
 id <0OL401400JAC6I00@st11p06im-asmtp001.me.com> for netdev@vger.kernel.org;
 Thu, 09 Feb 2017 20:25:46 +0000 (GMT)
In-reply-to: <2DAAE40C-75B6-48F6-B57F-1C72086929B9@me.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Feb 08, 2017, at 16:45, Denny Page <dennypage@me.com> wrote:
>=20
> [Resend as plain text]
>=20
>=20
>> On Feb 07, 2017, at 06:01, Miroslav Lichvar <mlichvar@redhat.com> =
wrote:
>>=20
>> 5) new SO_TIMESTAMPING options to get transposed RX timestamps
>>=20
>>  PTP uses preamble RX timestamps, but NTP works with trailer RX
>>  timestamps. This means NTP implementations currently need to
>>  transpose HW RX timestamps. The calculation requires the link speed
>>  and the length of the packet at layer 2. It seems this can be
>>  reliably done only using raw sockets. It would be very nice if the
>>  kernel could tranpose the timestamps automatically.
>>=20
>>  The existing SOF_TIMESTAMPING_RX_HARDWARE flag could be aliased to
>>  SOF_TIMESTAMPING_RX_HARDWARE_PREAMBLE and the new flag could be
>>  SOF_TIMESTAMPING_RX_HARDWARE_TRAILER.
>>=20
>>  PTP has a similar problem with SW RX timestamps, which are closer
>>  to the trailer timestamps rather than preamble timestamps. A new
>>  SOF_TIMESTAMPING_RX_SOFTWARE_PREAMBLE flag could be added for PTP
>>  implementations to get transposed timestamps in order to improve
>>  accuracy.
>>=20
>> 6) new SO_TIMESTAMPING option to get PHC index with HW timestamps
>>=20
>>  With bridges, bonding and other things it's difficult to determine
>>  which PHC timestamped the packet. It would be very useful if the
>>  PHC index was provided with each HW timestamp.
>>=20
>>  I'm not sure what would be the best place to put it. I guess the
>>  second timespec in scm_timestamping could be reused for this, but
>>  that sounds like a gross hack. Do we need to define a new struct?
>=20
>=20
> Miroslav, if #5 were implemented, would #6 still needed?
>=20
> Denny

Miroslav, please ignore this. Of course you still need the index in =
order to get the PHC offset. My bad.

Denny
