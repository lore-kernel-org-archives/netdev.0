From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 0/5] qed/qede: Tunnel hardware GRO support
Date: Wed, 22 Jun 2016 16:42:55 -0700
Message-ID: <1466638975.6850.102.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1466583926-27762-1-git-send-email-manish.chopra@qlogic.com>
	 <CAKgT0Ue6_cPb88wfTtMMetJzBSJnGDNWj8YVHWC=9WdztCxOuQ@mail.gmail.com>
	 <CO2PR11MB008891D4ECFF86F32B1C32CC972C0@CO2PR11MB0088.namprd11.prod.outlook.com>
	 <CAKgT0UdDt6H8ix6U7n_uPjodkXYuxviZjSKWQRaXu2_qWWEL+A@mail.gmail.com>
	 <CO2PR11MB0088C4DEAFEE71B0D865DB33972C0@CO2PR11MB0088.namprd11.prod.outlook.com>
	 <CAKgT0UeBZYP-Ax-iv-++9ODmf_F3Z3x1A_AGHgcuhEK21HsqPg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>,
	Manish Chopra <manish.chopra@qlogic.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Ariel Elior <Ariel.Elior@qlogic.com>,
	Tom Herbert <tom@herbertland.com>,
	Hannes Frederic Sowa <hannes@redhat.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:35258 "EHLO
	mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750862AbcFVXm5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2016 19:42:57 -0400
Received: by mail-pf0-f181.google.com with SMTP id c2so22184511pfa.2
        for <netdev@vger.kernel.org>; Wed, 22 Jun 2016 16:42:57 -0700 (PDT)
In-Reply-To: <CAKgT0UeBZYP-Ax-iv-++9ODmf_F3Z3x1A_AGHgcuhEK21HsqPg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-06-22 at 14:32 -0700, Alexander Duyck wrote:
	
> The idea behind GRO was to make it so that we had a generic way to
> handle this in software.  For the most part drivers doing LRO in
> software were doing the same thing that the GRO was doing.  The only
> reason it was deprecated is because GRO was capable of doing more than
> LRO could since we add one parser and suddenly all devices saw the
> benefit instead of just one specific device.  It is best to keep those
> two distinct solutions and then let the user sort out if they want to
> have the aggregation done by the device or the kernel.

Presumably we could add features flags to selectively enable part of LRO
(really simply GRO offloading) for NIC that partially match GRO
requirements.

Patch 5/5 seems to enable the hardware feature(s) :

+               p_ramrod->tpa_param.tpa_ipv4_tunn_en_flg = 1;
+               p_ramrod->tpa_param.tpa_ipv6_tunn_en_flg = 1;

So this NIC seems to have a way to control its LRO engine.

If some horrible bug happens for GRE+IPv6+TCP, you could disable LRO
coping with GRE encapsulation, instead of disabling whole LRO

We have software fallback. Nice, with quite heavy cpu cost.

If we can use offload without breaking rules, use it.

Some NIC have terrible LRO performance (I wont give details here),
but others are ok.

Some NIC have terrible TSO performance for small number of segments.
(gso_segs < 4)
