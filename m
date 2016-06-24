From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next 0/5] qed/qede: Tunnel hardware GRO support
Date: Fri, 24 Jun 2016 09:44:24 -0700
Message-ID: <CAKgT0Ud3RQjLFJZKX-MGphbdNi83c9q5QnaU4dV3X0WHGD-vLA@mail.gmail.com>
References: <1466583926-27762-1-git-send-email-manish.chopra@qlogic.com>
 <CAKgT0Ue6_cPb88wfTtMMetJzBSJnGDNWj8YVHWC=9WdztCxOuQ@mail.gmail.com>
 <CO2PR11MB008891D4ECFF86F32B1C32CC972C0@CO2PR11MB0088.namprd11.prod.outlook.com>
 <CAKgT0UdDt6H8ix6U7n_uPjodkXYuxviZjSKWQRaXu2_qWWEL+A@mail.gmail.com>
 <CO2PR11MB0088C4DEAFEE71B0D865DB33972C0@CO2PR11MB0088.namprd11.prod.outlook.com>
 <576B08A2.8080603@hpe.com> <1466635664.6850.90.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAKgT0UdbPVqpSVLs0JW7zFU7mNtJn5BM+fMjsr1tLm4kHRcW9A@mail.gmail.com>
 <1466638292.6850.94.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAKgT0Uex41aBJX84we2gxNGw6M4s5xGEPnDkGehTZkEE+i+Jhw@mail.gmail.com>
 <CO2PR11MB0088B3C577EC110B845C17B3972D0@CO2PR11MB0088.namprd11.prod.outlook.com>
 <CO2PR11MB0088949623FA99ED86D33205972D0@CO2PR11MB0088.namprd11.prod.outlook.com>
 <CAKgT0Uc7cCu-5SwrB+4Mv6OM+V1jDwefOoG-Wr61C4F1g1BmFA@mail.gmail.com>
 <CO2PR11MB00884BBC91DE36D3FA78796C972D0@CO2PR11MB0088.namprd11.prod.outlook.com>
 <CAKgT0UfPFsv6aH9aQQPD3gZ_0netSS85-mNLnb1bGjvtdyu6fw@mail.gmail.com> <CO2PR11MB0088862F73DF6A1F99DDAA6D972E0@CO2PR11MB0088.namprd11.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Rick Jones <rick.jones2@hpe.com>,
	Manish Chopra <manish.chopra@qlogic.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Ariel Elior <Ariel.Elior@qlogic.com>,
	Tom Herbert <tom@herbertland.com>,
	Hannes Frederic Sowa <hannes@redhat.com>
To: Yuval Mintz <Yuval.Mintz@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f43.google.com ([209.85.214.43]:35752 "EHLO
	mail-it0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751452AbcFXQo0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2016 12:44:26 -0400
Received: by mail-it0-f43.google.com with SMTP id g127so19398443ith.0
        for <netdev@vger.kernel.org>; Fri, 24 Jun 2016 09:44:26 -0700 (PDT)
In-Reply-To: <CO2PR11MB0088862F73DF6A1F99DDAA6D972E0@CO2PR11MB0088.namprd11.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 23, 2016 at 10:20 PM, Yuval Mintz <Yuval.Mintz@qlogic.com> wrote:
>>We already know of one firmware bug you guys have which makes
>>it clear that the bnx2x is not doing hardware assisted GRO it is doing
>>something else since it performs much worse than GRO if the MSS is
>>less than what it would be based on the MTU.
>
> It's a bit nitpicky, isn't it? Claiming this flaw means it's not GRO.
> I.e., you obviously wouldn't have claimed it beacme GRO if it
> was fixed.
>
> Not saying it makes a lot of difference, though.

The fact is LRO and GRO are two separate things.  Even without the bug
in the firmware I would still be saying the are two very different
things.  Your GRO implementation only supports a subset of the
features that GRO has in the hardware.  The way the kernel has
implemented things we should keep GRO and GSO symmetric if at all
possible.  There aren't currently any GSO hardware offloads so there
probably shouldn't be any GRO hardware offloads.  On the other hand
devices do support TSO hardware offloads so it would make sense to
match that up and support LRO as the hardware equivalent of GRO.

Anyway that is my opinion.  It may be nitpicky but I don't fee that we
should be re-purposing feature bits that were meant to be software
features to represent hardware ones.

- Alex
