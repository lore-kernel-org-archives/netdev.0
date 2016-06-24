From: Edward Cree <ecree@solarflare.com>
Subject: Re: [PATCH net-next 0/5] qed/qede: Tunnel hardware GRO support
Date: Fri, 24 Jun 2016 18:21:53 +0100
Message-ID: <9834a2dd-33c0-33b1-697e-49a39b1b7554@solarflare.com>
References: <1466583926-27762-1-git-send-email-manish.chopra@qlogic.com>
 <CO2PR11MB008891D4ECFF86F32B1C32CC972C0@CO2PR11MB0088.namprd11.prod.outlook.com>
 <CAKgT0UdDt6H8ix6U7n_uPjodkXYuxviZjSKWQRaXu2_qWWEL+A@mail.gmail.com>
 <CO2PR11MB0088C4DEAFEE71B0D865DB33972C0@CO2PR11MB0088.namprd11.prod.outlook.com>
 <576B08A2.8080603@hpe.com>
 <1466635664.6850.90.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAKgT0UdbPVqpSVLs0JW7zFU7mNtJn5BM+fMjsr1tLm4kHRcW9A@mail.gmail.com>
 <1466638292.6850.94.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAKgT0Uex41aBJX84we2gxNGw6M4s5xGEPnDkGehTZkEE+i+Jhw@mail.gmail.com>
 <CO2PR11MB0088B3C577EC110B845C17B3972D0@CO2PR11MB0088.namprd11.prod.outlook.com>
 <CO2PR11MB0088949623FA99ED86D33205972D0@CO2PR11MB0088.namprd11.prod.outlook.com>
 <CAKgT0Uc7cCu-5SwrB+4Mv6OM+V1jDwefOoG-Wr61C4F1g1BmFA@mail.gmail.com>
 <058fd87e-4dbe-f80e-0606-508956f339a7@solarflare.com>
 <CALx6S341Pb-fq+trudZDOY3SpFzJvyqhrTGQd+7t0hDc3Jr_ig@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	Yuval Mintz <Yuval.Mintz@qlogic.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Rick Jones <rick.jones2@hpe.com>,
	Manish Chopra <manish.chopra@qlogic.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Ariel Elior <Ariel.Elior@qlogic.com>,
	Hannes Frederic Sowa <hannes@redhat.com>,
	Bert Kenward <bkenward@solarflare.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo03.seg.att.com ([209.65.160.84]:53974 "EHLO
	nbfkord-smmo03.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751870AbcFXRWO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2016 13:22:14 -0400
In-Reply-To: <CALx6S341Pb-fq+trudZDOY3SpFzJvyqhrTGQd+7t0hDc3Jr_ig@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 24/06/16 17:31, Tom Herbert wrote:
> Ed,
> Because you took this OT... ;-)
>
> LRO/GRO is the one of the five common offloads that has no generic
> analogue and requires protocol specific logic. For instance each
> IP-over-foo encapsulation needs kernel code for GRO, device/driver
> code for LRO. I think the answer here is to make both GRO and LRO to
> be user programmable via BPF.
I agree that the only way to make LRO generic is to go for hardware
BPF.  However, I think that's likely to cause a _lot_ of headaches to
implement and my hope is that we can instead get acceptable receive
performance from GRO, RSS, and maybe things like the skb bundling I
posted a while back.
For instance, if your 'source port hack' were to mix in the TNI as
well as the inner flow fields it already uses, I think that could
improve hash spreading and thus GRO would perform better.
Fundamentally I believe that robust, responsive hardware LRO is not
workable as the hardware would have to decide to hold onto packets in
the hope of merge candidates arriving soon after.  Whereas in the
software layer (GRO, bundling...), the packets are already coming in
bursts thanks to the way napi polling behaves.
But I'd love to be proved wrong :)  The 'hybrid' approach of using
bpf in hw to identify flows for sw to gro does seem plausible, maybe
having bpf to compute the rxhash is the answer?

-Ed

(disclaimer: definitely not speaking for my employer here, these are
my personal views only.)
