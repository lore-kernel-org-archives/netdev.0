From: Denny Page <dennypage@me.com>
Subject: Re: Extending socket timestamping API for NTP
Date: Tue, 07 Feb 2017 19:06:50 -0800
Message-ID: <15CC0B95-9466-44AF-9922-3171F240FD76@me.com>
References: <20170207140144.GA11233@localhost>
 <CAHoNx58u=Fze4e5V2Wb_LiBhka1Mzny3zOVNfvuzjnmQ4wBO=Q@mail.gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 10.2 \(3259\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Cc: Miroslav Lichvar <mlichvar@redhat.com>, netdev@vger.kernel.org,
        Richard Cochran <richardcochran@gmail.com>,
        Jiri Benc <jbenc@redhat.com>,
        "Keller, Jacob E" <jacob.e.keller@intel.com>,
        Willem de Bruijn <willemb@google.com>
To: sdncurious <sdncurious@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from st11p06im-asmtp002.me.com ([17.172.125.150]:48438 "EHLO
        st11p06im-asmtp002.me.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752714AbdBHDGy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 22:06:54 -0500
Received: from process-dkim-sign-daemon.st11p06im-asmtp002.me.com by
 st11p06im-asmtp002.me.com
 (Oracle Communications Messaging Server 7.0.5.38.0 64bit (built Feb 26 2016))
 id <0OL100Y00CFHL000@st11p06im-asmtp002.me.com> for netdev@vger.kernel.org;
 Wed, 08 Feb 2017 03:06:53 +0000 (GMT)
In-reply-to: <CAHoNx58u=Fze4e5V2Wb_LiBhka1Mzny3zOVNfvuzjnmQ4wBO=Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Resend without rich text]

On Feb 07, 2017, at 12:17, sdncurious <sdncurious@gmail.com> wrote:
>  If the NTP has access to the physical layer, then the timestamps are
>    associated with the beginning of the symbol after the start of =
frame.
>    Otherwise, implementations should attempt to associate the =
timestamp
>    to the earliest accessible point in the frame.

The spec is unfortunately a bit ambiguous and probably should be =
clarified.

NTP is sensitive to transmission asymmetry. While using the SFD is =
appropriate for transmit timestamps, it is not appropriate for receive =
timestamps. A simple reason for this is port speed mismatch. Consider a =
1Gb entity communicating with a 100Mb entity on a local switch: leaving =
aside internal switch delays, if SFD timestamping is used for both =
transmit and receive, then there is a baked in asymmetry of 6768ns =
between the forward and reverse paths; if SFD is used for transmit, and =
FCS end is used for receive, there is no asymmetry.

There is a good explanation of this written by David Mills (NTP's =
author) here: https://www.eecis.udel.edu/~mills/stamp.html#require

Denny
