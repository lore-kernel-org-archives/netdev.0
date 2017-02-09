From: Denny Page <dennypage@me.com>
Subject: Re: Extending socket timestamping API for NTP
Date: Wed, 08 Feb 2017 16:45:05 -0800
Message-ID: <2DAAE40C-75B6-48F6-B57F-1C72086929B9@me.com>
References: <20170207140144.GA11233@localhost>
Mime-Version: 1.0 (Mac OS X Mail 10.2 \(3259\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Richard Cochran <richardcochran@gmail.com>,
        Jiri Benc <jbenc@redhat.com>,
        "Keller, Jacob E" <jacob.e.keller@intel.com>,
        Willem de Bruijn <willemb@google.com>
To: Miroslav Lichvar <mlichvar@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from st13p35im-asmtp001.me.com ([17.164.199.64]:37135 "EHLO
        st13p35im-asmtp001.me.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751055AbdBIFrK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 00:47:10 -0500
Received: from process-dkim-sign-daemon.st13p35im-asmtp001.me.com by
 st13p35im-asmtp001.me.com
 (Oracle Communications Messaging Server 7.0.5.38.0 64bit (built Feb 26 2016))
 id <0OL300H000HNOL00@st13p35im-asmtp001.me.com> for netdev@vger.kernel.org;
 Thu, 09 Feb 2017 00:45:08 +0000 (GMT)
In-reply-to: <20170207140144.GA11233@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Resend as plain text]


> On Feb 07, 2017, at 06:01, Miroslav Lichvar <mlichvar@redhat.com> wrote:
> 
> 5) new SO_TIMESTAMPING options to get transposed RX timestamps
> 
>   PTP uses preamble RX timestamps, but NTP works with trailer RX
>   timestamps. This means NTP implementations currently need to
>   transpose HW RX timestamps. The calculation requires the link speed
>   and the length of the packet at layer 2. It seems this can be
>   reliably done only using raw sockets. It would be very nice if the
>   kernel could tranpose the timestamps automatically.
> 
>   The existing SOF_TIMESTAMPING_RX_HARDWARE flag could be aliased to
>   SOF_TIMESTAMPING_RX_HARDWARE_PREAMBLE and the new flag could be
>   SOF_TIMESTAMPING_RX_HARDWARE_TRAILER.
> 
>   PTP has a similar problem with SW RX timestamps, which are closer
>   to the trailer timestamps rather than preamble timestamps. A new
>   SOF_TIMESTAMPING_RX_SOFTWARE_PREAMBLE flag could be added for PTP
>   implementations to get transposed timestamps in order to improve
>   accuracy.
> 
> 6) new SO_TIMESTAMPING option to get PHC index with HW timestamps
> 
>   With bridges, bonding and other things it's difficult to determine
>   which PHC timestamped the packet. It would be very useful if the
>   PHC index was provided with each HW timestamp.
> 
>   I'm not sure what would be the best place to put it. I guess the
>   second timespec in scm_timestamping could be reused for this, but
>   that sounds like a gross hack. Do we need to define a new struct?


Miroslav, if #5 were implemented, would #6 still needed?

Denny
