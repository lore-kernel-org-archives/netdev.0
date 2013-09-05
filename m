From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH] openvswitch: fix sw_flow_key alignment
Date: Thu, 5 Sep 2013 10:37:00 -0700
Message-ID: <CAEP_g=9+wQCuUBPEHbu8M7WEe4BKY5jMK8a7TH23Y_gQVAYWEg@mail.gmail.com>
References: <CAEP_g=9y-HeG0vHS2v-dk7eDp=T0denddykDO3TJtk4UJ062Mg@mail.gmail.com>
 <20130830.144211.1550393719904034493.davem@davemloft.net> <CAEP_g=-zgaKot6f5w=sqVjOauT9OtSd1sjrJSwc5AC7xR1s99g@mail.gmail.com>
 <20130831.001650.130549489746201651.davem@davemloft.net> <CAEP_g=-9ezK5MqiHKvKuFNn3SVoGBRy7p6V5JanKFFG86i8EDw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andy Zhou <azhou@nicira.com>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog110.obsmtp.com ([74.125.149.203]:44796 "HELO
	na3sys009aog110.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752697Ab3IERhV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Sep 2013 13:37:21 -0400
Received: by mail-lb0-f179.google.com with SMTP id x18so1896892lbi.24
        for <netdev@vger.kernel.org>; Thu, 05 Sep 2013 10:37:20 -0700 (PDT)
In-Reply-To: <CAEP_g=-9ezK5MqiHKvKuFNn3SVoGBRy7p6V5JanKFFG86i8EDw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 3, 2013 at 3:06 PM, Jesse Gross <jesse@nicira.com> wrote:
> On Fri, Aug 30, 2013 at 9:16 PM, David Miller <davem@davemloft.net> wrote:
>> From: Jesse Gross <jesse@nicira.com>
>> Date: Fri, 30 Aug 2013 16:20:25 -0700
>>
>>> I looked through the struct definition and I think that the idea of
>>> manually padding as Geert did in his patch will be difficult to
>>> maintain over time (and actually there are a few that he missed) since
>>> there are a number of different structs/unions contained in there.
>>
>> You have to be mindful of the gaps and wasted space for performance
>> reasons anyways.
>
> Yes, although the approaches for performance and correctness are not
> necessarily the same. For example, we're taking about potentially
> packing the struct, in which case we would still have the same
> alignment needs even without any gaps. If the correctness is clearly
> handled (through an explicit align and build assert) then it's easier
> to pack/rearrange/whatever for performance since the whole thing isn't
> fragile.

I'd like to get this build failure fixed soon, so I'll just send out a
minimal fix that seems best to me in a couple of minutes.
