From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH v5 net-next 5/7] net: fix documentation of struct scm_timestamping
Date: Fri, 19 May 2017 11:23:49 -0400
Message-ID: <CAF=yD-+cnSTQjed3UuMrCk8yiHdweqxvXCfunqd=eKmEFHRfvw@mail.gmail.com>
References: <20170518140738.19617-1-mlichvar@redhat.com> <20170518140738.19617-6-mlichvar@redhat.com>
 <CAF=yD-JGUw6pryNV3YevFMxC5=1A62qujAfFO7LjQi2LtsSg4g@mail.gmail.com> <20170519101118.GD21003@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Network Development <netdev@vger.kernel.org>,
        Richard Cochran <richardcochran@gmail.com>,
        Willem de Bruijn <willemb@google.com>
To: Miroslav Lichvar <mlichvar@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:33485 "EHLO
        mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750783AbdESPYa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 May 2017 11:24:30 -0400
Received: by mail-oi0-f65.google.com with SMTP id h4so12895870oib.0
        for <netdev@vger.kernel.org>; Fri, 19 May 2017 08:24:30 -0700 (PDT)
In-Reply-To: <20170519101118.GD21003@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 19, 2017 at 6:11 AM, Miroslav Lichvar <mlichvar@redhat.com> wrote:
> On Thu, May 18, 2017 at 03:38:30PM -0400, Willem de Bruijn wrote:
>> On Thu, May 18, 2017 at 10:07 AM, Miroslav Lichvar <mlichvar@redhat.com> wrote:
>> > +Note that if the SO_TIMESTAMP or SO_TIMESTAMPNS option is enabled
>> > +together with SO_TIMESTAMPING using SOF_TIMESTAMPING_SOFTWARE, a false
>> > +software timestamp will be generated in the recvmsg() call and passed
>> > +in ts[0] when a real software timestamp is missing.
>>
>> With receive software timestamping this is expected behavior? I would make
>> explicit that this happens even on tx timestamps.
>
> How about adding ", e.g. when receive timestamping is enabled
> between receiving the message and the recvmsg() call, or it is a
> message with a hardware transmit timestamp." ?

Perhaps even more brief "This happens also on hardware tx timestamps."

>> > For this reason it
>> > +is not recommended to combine SO_TIMESTAMP(NS) with SO_TIMESTAMPING.
>>
>> And I'd remove this. The extra timestamp is harmless, and we may be missing
>> other reasons why someone would want to enable both on the same socket.
>
> Ok. I'm just concerned people will inadvertently use the timestamp as
> a real timestamp and then wonder why SW TX timestamping is so bad. I
> have fallen into this trap.

So have I. It is equally surprising when only enabling SO_TIMESTAMP and
observing out of order timestamps. It is certainly worth calling out.
