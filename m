From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next 0/5] qed/qede: Tunnel hardware GRO support
Date: Wed, 22 Jun 2016 16:59:05 -0700
Message-ID: <CALx6S36jA7JTwm_gS8n5_xt-7vK4jwarOeoC=30S-zwREoo63Q@mail.gmail.com>
References: <1466583926-27762-1-git-send-email-manish.chopra@qlogic.com>
 <CAKgT0Ue6_cPb88wfTtMMetJzBSJnGDNWj8YVHWC=9WdztCxOuQ@mail.gmail.com>
 <CO2PR11MB008891D4ECFF86F32B1C32CC972C0@CO2PR11MB0088.namprd11.prod.outlook.com>
 <CAKgT0UdDt6H8ix6U7n_uPjodkXYuxviZjSKWQRaXu2_qWWEL+A@mail.gmail.com>
 <CO2PR11MB0088C4DEAFEE71B0D865DB33972C0@CO2PR11MB0088.namprd11.prod.outlook.com>
 <576B08A2.8080603@hpe.com> <1466635664.6850.90.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAKgT0UdbPVqpSVLs0JW7zFU7mNtJn5BM+fMjsr1tLm4kHRcW9A@mail.gmail.com> <1466638292.6850.94.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	Rick Jones <rick.jones2@hpe.com>,
	Yuval Mintz <Yuval.Mintz@qlogic.com>,
	Manish Chopra <manish.chopra@qlogic.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Ariel Elior <Ariel.Elior@qlogic.com>,
	Hannes Frederic Sowa <hannes@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f52.google.com ([209.85.214.52]:38756 "EHLO
	mail-it0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751447AbcFVX7H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2016 19:59:07 -0400
Received: by mail-it0-f52.google.com with SMTP id h190so52578577ith.1
        for <netdev@vger.kernel.org>; Wed, 22 Jun 2016 16:59:07 -0700 (PDT)
In-Reply-To: <1466638292.6850.94.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 22, 2016 at 4:31 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2016-06-22 at 15:56 -0700, Alexander Duyck wrote:
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
> Well, we offload TSO to the NIC. Or checksums as much as we can.
>
> At one point we have to trust the NIC we plug in our hosts, right ?
>
> Why RX is so different than TX exactly ?
>
LRO requires parsing the packet and hence DPI for things like foo/UDP.
TSO is much more straightforward and does not rely on parsing (e.g.
LRO would require NIC to parse EH, TSO doesn't). Also, TSO is
work-conserving, whereas LRO is not. I don't believe there is any
standard for how NICs are supposed to determined when to set packets
to host. All of this makes LRO much less deterministic and means
there's a lot of variance between NIC implementations. Plus there's
also the question of whether a vendor is testing IPv6. I do think all
this can be "fixed" once we have programmable NICs and we can program
our own implementation of LRO, but until then I think there is
inherent risk in using it. GRO rocks though!

Tom

> Yes, LRO is hard to implement properly compared to TSO,
> but not something that is _fundamentally_ broken.
>
> Claiming that hardware assist GRO is not possible is a plain mantra.
>
>
