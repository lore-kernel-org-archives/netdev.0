From: sdncurious <sdncurious@gmail.com>
Subject: Re: Extending socket timestamping API for NTP
Date: Tue, 7 Feb 2017 12:37:15 -0800
Message-ID: <CAHoNx59VwLbACPp_3a5doyi=Y1hUqU5oVvJqxpsv777W2g+Z8w@mail.gmail.com>
References: <20170207140144.GA11233@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, Richard Cochran <richardcochran@gmail.com>,
        Jiri Benc <jbenc@redhat.com>,
        "Keller, Jacob E" <jacob.e.keller@intel.com>,
        Denny Page <dennypage@me.com>,
        Willem de Bruijn <willemb@google.com>
To: Miroslav Lichvar <mlichvar@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f53.google.com ([209.85.214.53]:34401 "EHLO
        mail-it0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754414AbdBGUhR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 15:37:17 -0500
Received: by mail-it0-f53.google.com with SMTP id k200so29612116itb.1
        for <netdev@vger.kernel.org>; Tue, 07 Feb 2017 12:37:16 -0800 (PST)
In-Reply-To: <20170207140144.GA11233@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 7, 2017 at 6:01 AM, Miroslav Lichvar <mlichvar@redhat.com> wrote:


> 5) new SO_TIMESTAMPING options to get transposed RX timestamps
>
>    PTP uses preamble RX timestamps, but NTP works with trailer RX
>    timestamps. This means NTP implementations currently need to
>    transpose HW RX timestamps. The calculation requires the link speed
>    and the length of the packet at layer 2. It seems this can be
>    reliably done only using raw sockets. It would be very nice if the
>    kernel could tranpose the timestamps automatically.

Is this a requirement ? RFC 5905 does not seem to imply this and a
search  does not show any issues being reported.
>From RFC 5905

   Reference Timestamp: Time when the system clock was last set or
   corrected, in NTP timestamp format.

   Origin Timestamp (org): Time at the client when the request departed
   for the server, in NTP timestamp format.

   Receive Timestamp (rec): Time at the server when the request arrived
   from the client, in NTP timestamp format.

   Transmit Timestamp (xmt): Time at the server when the response left
   for the client, in NTP timestamp format.

   Destination Timestamp (dst): Time at the client when the reply
   arrived from the server, in NTP timestamp format.

   Note: The Destination Timestamp field is not included as a header
   field; it is determined upon arrival of the packet and made available
   in the packet buffer data structure.

   If the NTP has access to the physical layer, then the timestamps are
   associated with the beginning of the symbol after the start of frame.
   Otherwise, implementations should attempt to associate the timestamp
   to the earliest accessible point in the frame.



>
>    The existing SOF_TIMESTAMPING_RX_HARDWARE flag could be aliased to
>    SOF_TIMESTAMPING_RX_HARDWARE_PREAMBLE and the new flag could be
>    SOF_TIMESTAMPING_RX_HARDWARE_TRAILER.
>
>    PTP has a similar problem with SW RX timestamps, which are closer
>    to the trailer timestamps rather than preamble timestamps. A new
>    SOF_TIMESTAMPING_RX_SOFTWARE_PREAMBLE flag could be added for PTP
>    implementations to get transposed timestamps in order to improve
>    accuracy.


>
> 6) new SO_TIMESTAMPING option to get PHC index with HW timestamps
>
>    With bridges, bonding and other things it's difficult to determine
>    which PHC timestamped the packet. It would be very useful if the
>    PHC index was provided with each HW timestamp.
>
>    I'm not sure what would be the best place to put it. I guess the
>    second timespec in scm_timestamping could be reused for this, but
>    that sounds like a gross hack. Do we need to define a new struct?

What is the use case for this. even if the delay though the PHY's how
would that be compensated ?

RMS
>
> Thoughts?
>
> --
> Miroslav Lichvar
