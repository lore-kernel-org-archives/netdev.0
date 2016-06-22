From: Rick Jones <rick.jones2@hpe.com>
Subject: Re: [PATCH net-next 0/5] qed/qede: Tunnel hardware GRO support
Date: Wed, 22 Jun 2016 16:52:25 -0700
Message-ID: <576B24B9.604@hpe.com>
References: <1466583926-27762-1-git-send-email-manish.chopra@qlogic.com>
 <CAKgT0Ue6_cPb88wfTtMMetJzBSJnGDNWj8YVHWC=9WdztCxOuQ@mail.gmail.com>
 <CO2PR11MB008891D4ECFF86F32B1C32CC972C0@CO2PR11MB0088.namprd11.prod.outlook.com>
 <CAKgT0UdDt6H8ix6U7n_uPjodkXYuxviZjSKWQRaXu2_qWWEL+A@mail.gmail.com>
 <CO2PR11MB0088C4DEAFEE71B0D865DB33972C0@CO2PR11MB0088.namprd11.prod.outlook.com>
 <576B08A2.8080603@hpe.com>
 <1466635664.6850.90.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAKgT0UdbPVqpSVLs0JW7zFU7mNtJn5BM+fMjsr1tLm4kHRcW9A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>,
	Manish Chopra <manish.chopra@qlogic.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Ariel Elior <Ariel.Elior@qlogic.com>,
	Tom Herbert <tom@herbertland.com>,
	Hannes Frederic Sowa <hannes@redhat.com>
To: Alexander Duyck <alexander.duyck@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g2t2354.austin.hpe.com ([15.233.44.27]:1786 "EHLO
	g2t2354.austin.hpe.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750874AbcFVXw1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2016 19:52:27 -0400
In-Reply-To: <CAKgT0UdbPVqpSVLs0JW7zFU7mNtJn5BM+fMjsr1tLm4kHRcW9A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/22/2016 03:56 PM, Alexander Duyck wrote:
> On Wed, Jun 22, 2016 at 3:47 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> On Wed, 2016-06-22 at 14:52 -0700, Rick Jones wrote:
>>> Had the bnx2x-driven NICs' firmware not had that rather unfortunate
>>> assumption about MSSes I probably would never have noticed.


> It could be that you and Rick are running different firmware. I
> believe you can expose that via "ethtool -i".  This is the ugly bit
> about all this.  We are offloading GRO into the firmware of these
> devices with no idea how any of it works and by linking GRO to LRO on
> the same device you are stuck having to accept either the firmware
> offload or nothing at all.  That is kind of the point Rick was trying
> to get at.

I think you are typing a bit too far ahead into my keyboard with that 
last sentence.  And I may not have been sufficiently complete in what I 
wrote.  If the bnx2x-driven NICs' firmware had been coalescing more than 
two segments together, not only would I probably not have noticed, I 
probably would not have been upset to learn it was NIC-firmware GRO 
rather than stack.

My complaint is the specific bug of coalescing only two segments when 
their size is unexpected, and the difficulty present in disabling the 
bnx2x-driven NICs' firmware GRO.  I don't have a problem necessarily 
with the existence of NIC-firmware GRO in general.  I just want to be 
able to enable/disable it easily.

rick jones

Of course, what I really want are much, Much, MUCH larger MTUs.  It 
isn't for nothing that I used to refer to TSO as "Poor man's Jumbo 
Frames" :)
