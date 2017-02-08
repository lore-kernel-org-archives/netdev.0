From: sdncurious <sdncurious@gmail.com>
Subject: Re: Extending socket timestamping API for NTP
Date: Wed, 8 Feb 2017 15:27:13 -0800
Message-ID: <CAHoNx5-MVUSU1bUScE+Ni6yeNqC5qeRh-00fSiJ5Ny9zNixh4A@mail.gmail.com>
References: <20170207140144.GA11233@localhost> <CAHoNx59VwLbACPp_3a5doyi=Y1hUqU5oVvJqxpsv777W2g+Z8w@mail.gmail.com>
 <20170208102623.GC11233@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
        Richard Cochran <richardcochran@gmail.com>,
        Jiri Benc <jbenc@redhat.com>,
        "Keller, Jacob E" <jacob.e.keller@intel.com>,
        Denny Page <dennypage@me.com>,
        Willem de Bruijn <willemb@google.com>
To: Miroslav Lichvar <mlichvar@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f170.google.com ([209.85.223.170]:32864 "EHLO
        mail-io0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751235AbdBHX2c (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 18:28:32 -0500
Received: by mail-io0-f170.google.com with SMTP id v96so3872868ioi.0
        for <netdev@vger.kernel.org>; Wed, 08 Feb 2017 15:27:14 -0800 (PST)
In-Reply-To: <20170208102623.GC11233@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dealing with individual interfaces does not make sense. This seems to be a
case where Reciprocity property is violated and hence should be handled as
such. This is different than when the two sides have single but different
speed NIC's. In this case the NIC used and the speed can change with each
packet. Although I am not sure if that is possible because the hash should
always land the packet on the NIC of the bond.

7. Reciprocity Errors

The above analysis assumes that the delays on the outbound and inbound
paths are the same; that is, the paths are reciprocal. This is assured if
the ropagation delays are the same, the transmission rates are the same and
the packet lengths are the same. In the NTP on-wire protocol all packets
have the the same length. If we assume the transmission rates are the same,
the only difference in path delays must be due to nonreciprocal
transmission paths. This often occurs if one way is via landline and the
other via satellite. It can also occur when the paths traverse tag-switched
core networks.

RMS

On Wed, Feb 8, 2017 at 2:26 AM, Miroslav Lichvar <mlichvar@redhat.com> wrote:
> On Tue, Feb 07, 2017 at 12:37:15PM -0800, sdncurious wrote:
>> On Tue, Feb 7, 2017 at 6:01 AM, Miroslav Lichvar <mlichvar@redhat.com> wrote:
>> > 6) new SO_TIMESTAMPING option to get PHC index with HW timestamps
>> >
>> >    With bridges, bonding and other things it's difficult to determine
>> >    which PHC timestamped the packet. It would be very useful if the
>> >    PHC index was provided with each HW timestamp.
>> >
>> >    I'm not sure what would be the best place to put it. I guess the
>> >    second timespec in scm_timestamping could be reused for this, but
>> >    that sounds like a gross hack. Do we need to define a new struct?
>>
>> What is the use case for this. even if the delay though the PHY's how
>> would that be compensated ?
>
> The idea was that applications like NTP servers and clients wouldn't
> have to care about interfaces and how they map together with addresses
> to PHCs over time. Currently, I use the interface index from
> IP_PKTINFO to get the PHC, but that doesn't work with bridges and
> other virtual interfaces. Another possibility would be an option to
> modify the behavior of IP_PKTINFO to save the index of the real
> interface. I'm not sure how would that compare in difficulty to
> extending SCM_TIMESTAMPING with PHC index.
>
> --
> Miroslav Lichvar
