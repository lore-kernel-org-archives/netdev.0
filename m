From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next 0/5] qed/qede: Tunnel hardware GRO support
Date: Wed, 22 Jun 2016 17:18:51 -0700
Message-ID: <CAKgT0UcG_QnxXJs9GU7MwgBtUNY4KNKqzPiRKHoRJYJsTaUZ6g@mail.gmail.com>
References: <1466583926-27762-1-git-send-email-manish.chopra@qlogic.com>
 <CAKgT0Ue6_cPb88wfTtMMetJzBSJnGDNWj8YVHWC=9WdztCxOuQ@mail.gmail.com>
 <CO2PR11MB008891D4ECFF86F32B1C32CC972C0@CO2PR11MB0088.namprd11.prod.outlook.com>
 <CAKgT0UdDt6H8ix6U7n_uPjodkXYuxviZjSKWQRaXu2_qWWEL+A@mail.gmail.com>
 <CO2PR11MB0088C4DEAFEE71B0D865DB33972C0@CO2PR11MB0088.namprd11.prod.outlook.com>
 <576B08A2.8080603@hpe.com> <1466635664.6850.90.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAKgT0UdbPVqpSVLs0JW7zFU7mNtJn5BM+fMjsr1tLm4kHRcW9A@mail.gmail.com> <576B24B9.604@hpe.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Yuval Mintz <Yuval.Mintz@qlogic.com>,
	Manish Chopra <manish.chopra@qlogic.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Ariel Elior <Ariel.Elior@qlogic.com>,
	Tom Herbert <tom@herbertland.com>,
	Hannes Frederic Sowa <hannes@redhat.com>
To: Rick Jones <rick.jones2@hpe.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f177.google.com ([209.85.223.177]:36033 "EHLO
	mail-io0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751427AbcFWASx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2016 20:18:53 -0400
Received: by mail-io0-f177.google.com with SMTP id s63so54461327ioi.3
        for <netdev@vger.kernel.org>; Wed, 22 Jun 2016 17:18:53 -0700 (PDT)
In-Reply-To: <576B24B9.604@hpe.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 22, 2016 at 4:52 PM, Rick Jones <rick.jones2@hpe.com> wrote:
> On 06/22/2016 03:56 PM, Alexander Duyck wrote:
>>
>> On Wed, Jun 22, 2016 at 3:47 PM, Eric Dumazet <eric.dumazet@gmail.com>
>> wrote:
>>>
>>> On Wed, 2016-06-22 at 14:52 -0700, Rick Jones wrote:
>>>>
>>>> Had the bnx2x-driven NICs' firmware not had that rather unfortunate
>>>> assumption about MSSes I probably would never have noticed.
>
>
>
>> It could be that you and Rick are running different firmware. I
>> believe you can expose that via "ethtool -i".  This is the ugly bit
>> about all this.  We are offloading GRO into the firmware of these
>> devices with no idea how any of it works and by linking GRO to LRO on
>> the same device you are stuck having to accept either the firmware
>> offload or nothing at all.  That is kind of the point Rick was trying
>> to get at.
>
>
> I think you are typing a bit too far ahead into my keyboard with that last
> sentence.  And I may not have been sufficiently complete in what I wrote.
> If the bnx2x-driven NICs' firmware had been coalescing more than two
> segments together, not only would I probably not have noticed, I probably
> would not have been upset to learn it was NIC-firmware GRO rather than
> stack.
>
> My complaint is the specific bug of coalescing only two segments when their
> size is unexpected, and the difficulty present in disabling the bnx2x-driven
> NICs' firmware GRO.  I don't have a problem necessarily with the existence
> of NIC-firmware GRO in general.  I just want to be able to enable/disable it
> easily.

Right.  Which is why I thought we were supposed to be using the LRO
flag when a NIC is performing the GRO instead of it being done by the
kernel.

I have no problem with us doing hardware GRO.  The only issue I have
is with us identifying it as GRO.

In my opinion the way I would have preferred to have seen the bnx2x
handle all this is to make it that the NETIF_F_LRO flag controlled if
the NIC performed aggregation or not and the module parameter
determine if the LRO conforms to the GRO type layout for the frame.

As it is now I can easily see this causing issues if someone updates
how GRO/GSO handles frames without realizing they now need to make
sure the bnx2x and qede drivers need to generate the same frame layout
as well.

- Alex
