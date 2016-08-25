From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [RFC PATCH 3/5] bnx2x: Add support for segmentation of tunnels
 with outer checksums
Date: Thu, 25 Aug 2016 11:26:00 -0700
Message-ID: <CAKgT0Uf194vxfsMU8-OC2jFQhv7aNbr+gbUzD9uH_o=oyC1=2Q@mail.gmail.com>
References: <20160419185949.11723.50506.stgit@ahduyck-xeon-server>
 <20160419190609.11723.8710.stgit@ahduyck-xeon-server> <CO2PR11MB0088207088FA6F6A502AB3B097EA0@CO2PR11MB0088.namprd11.prod.outlook.com>
 <CAKgT0Uc3CMzvChw2ifaw4Gz+i=udaZsS8m4Qn8adL6ZoXor5wQ@mail.gmail.com> <CO2PR11MB008820D7EEE1788F55A3BE4997ED0@CO2PR11MB0088.namprd11.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Yuval Mintz <Yuval.Mintz@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f41.google.com ([209.85.214.41]:35537 "EHLO
        mail-it0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755448AbcHYSeI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2016 14:34:08 -0400
Received: by mail-it0-f41.google.com with SMTP id x131so288244084ite.0
        for <netdev@vger.kernel.org>; Thu, 25 Aug 2016 11:34:07 -0700 (PDT)
In-Reply-To: <CO2PR11MB008820D7EEE1788F55A3BE4997ED0@CO2PR11MB0088.namprd11.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 24, 2016 at 10:06 PM, Yuval Mintz <Yuval.Mintz@qlogic.com> wrote:
>> >> This patch assumes that the bnx2x hardware will ignore existing
>> >> IPv4/v6 header fields for length and checksum as well as the length
>> >> and checksum fields for outer UDP and GRE headers.
>> >>
>> >> I have no means of testing this as I do not have any bnx2x hardware
>> >> but thought I would submit it as an RFC to see if anyone out there
>> >> wants to test this and see if this does in fact enable this
>> >> functionality allowing us to to segment tunneled frames that have an outer
>> checksum.
>> >>
>> >> Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
>> >
>> > So it took me some [well, a lot] time to reach this, but I've finally  gave it a try.
>> > I saw a performance boost with the partial support - Throughput for
>> > vxlan tunnels with and without udpcsum were almost identical after
>> > this, whereas without this patch the udpcsum prevented GSO and a
>> > TCP/IPv4 connection on top of it got roughly half the throughput.
>> >
>> > However, I did encounter one oddity I couldn't explain - After I've
>> > disabled tx-udp_tnl-segmentation via ethtool on the base interface,
>> > got left with:
>> >    tx-gso-partial: on
>> >    tx-udp_tnl-segmentation: off
>> >    tx-udp_tnl-csum-segmentation: on
>> >
>> > When I ran traffic over both vxlan tunnels the one with the udpcsum
>> > was still Passing gso aggregations to base device to transmit [and the
>> > throughput was same as before], where's the tunnel without the udpcsum
>> > showed only MTU-sized packets reaching the base interface for
>> > transmission [which is what I've expected]
>> >
>> > Any idea why that happened?
>>
>> So the way they are implemented tx-udp_tnl-segmentation and tx-udp_tnl-
>> csum-segmentation are treated as two separate features.
>> The kernel currently gives them the same treatment as NETIF_F_TSO and
>> NETIF_F_TSO6.  You can disable one and the other still functions.
>>
>> Now if you disable tx-gso-partial you should expect to see tx-udp_tnl-csum-
>> segmentation be disabled because it is dependent on the partial GSO offload.
>>
>> - Alex
>
> O.k., thanks.
> Then I'll run some more testing scenarios, and assuming everything works
> fine I'll re-send this. Alex - should I place you at the 'from' field?

If you could do that, then that would be great.  I'm not working at
Mirantis anymore, but I don't believe that the account is setup to
bounce the email so it shouldn't generate any noise for Dave.  If not
you can just leave my original signed off by and add yours if you
want.

- Alex
