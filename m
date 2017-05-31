From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [i40e] regression on TCP stream and TCP maerts, kernel-4.12.0-0.rc2
Date: Wed, 31 May 2017 14:42:32 -0700
Message-ID: <CAKgT0Ucg9wHrKDBjQXKH6gziuinwcK9MO-jRC=0q60Lm-8vFqA@mail.gmail.com>
References: <655ed9ab-853e-7497-9ea3-cc8d13f56043@redhat.com>
 <CAKgT0UcdJQWqr_zxxi36a6_3iMwBNow-YS723i7t6xsKvAqvCA@mail.gmail.com>
 <CAKgT0Ufb41o=WM=3DM9cwvrw9N5AFn-uL0p1gQB-m+D3BX3DKA@mail.gmail.com> <1496238507.22688.4.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: Adam Okuliar <aokuliar@redhat.com>,
        Mitch Williams <mitch.a.williams@intel.com>,
        intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
        Netdev <netdev@vger.kernel.org>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        Otto Sabart <osabart@redhat.com>,
        Jirka Hladky <jhladky@redhat.com>
To: Adrian Tomasov <atomasov@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f181.google.com ([209.85.216.181]:35361 "EHLO
        mail-qt0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750898AbdEaVmd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 May 2017 17:42:33 -0400
Received: by mail-qt0-f181.google.com with SMTP id v27so23066585qtg.2
        for <netdev@vger.kernel.org>; Wed, 31 May 2017 14:42:33 -0700 (PDT)
In-Reply-To: <1496238507.22688.4.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 31, 2017 at 6:48 AM, Adrian Tomasov <atomasov@redhat.com> wrote=
:
> On Tue, 2017-05-30 at 18:27 -0700, Alexander Duyck wrote:
>> On Tue, May 30, 2017 at 8:41 AM, Alexander Duyck
>> <alexander.duyck@gmail.com> wrote:
>> >
>> > On Tue, May 30, 2017 at 6:43 AM, Adam Okuliar <aokuliar@redhat.com>
>> > wrote:
>> > >
>> > > Hello,
>> > >
>> > > we found regression on intel card(XL710) with i40e driver.
>> > > Regression is
>> > > about ~45%
>> > > on TCP_STREAM and TCP_MAERTS test for IPv4 and IPv6. Regression
>> > > was first
>> > > visible in kernel-4.12.0-0.rc1.
>> > >
>> > > More details about results you can see in uploaded images in
>> > > bugzilla. [0]
>> > >
>> > >
>> > > [0] https://bugzilla.kernel.org/show_bug.cgi?id=3D195923
>> > >
>> > >
>> > > Best regards, / S pozdravom,
>> > >
>> > > Adri=C3=A1n Toma=C5=A1ov
>> > > Kernel Performance QE
>> > > atomasov@redhat.com
>> >
>> > I have added the i40e driver maintainer and the intel-wired-lan
>> > mailing list so that we can make are developers aware of the issue.
>> >
>> > Thanks.
>> >
>> > - Alex
>>
>> Adam,
>>
>> We are having some issues trying to reproduce what you reported.
>>
>> Can you provide some additional data. Specifically we would be
>> looking
>> for an "ethtool -i", and an "ethtool -S" for the port before and
>> after
>> the test. If you can attach it to the bugzilla that would be
>> appreciated.
>>
>> Thanks.
>>
>> - Alex
>
> Hello Alex,
>
> requested files are updated in bugzilla.
>
> If you have any questions about testing feel free to ask.
>
>
> Best regards,
>
> Adrian

So looking at the data I wonder if we don't have an MTU mismatch in
the network config. I notice the "after" has rx_length_errors being
reported. Recent changes made it so that i40e doesn't support jumbo
frames by default, whereas before we could. You might want to check
for that as that could cause the kind of performance issues you are
seeing.

- Alex
