From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Subject: Re: [RFC] dccp ccid-3: High-res or low-res timers?
Date: Wed, 19 Nov 2008 06:41:08 +1300
Message-ID: <5640c7e00811180941l671fd3a0w390529df9222163e@mail.gmail.com>
References: <5bc4c4570811060538h2d662507u5de1fb62c61cd569@mail.gmail.com>
	 <20081106153824.GA9709@ghostprotocols.net>
	 <5bc4c4570811060946j4d5d8d1mf88f8b92c72b59c7@mail.gmail.com>
	 <5bc4c4570811061004nfc2afdcn6035d49ae654aef1@mail.gmail.com>
	 <5bc4c4570811061017j3acef860vee84992e7295d06d@mail.gmail.com>
	 <5bc4c4570811061405qe72e43cx861c537885804132@mail.gmail.com>
	 <20081108085035.GA7112@gerrit.erg.abdn.ac.uk>
	 <20081115105042.GA7798@gerrit.erg.abdn.ac.uk>
	 <5640c7e00811160014p17414c54v2499c5b1e996278f@mail.gmail.com>
	 <20081118061414.GA4015@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: "Gerrit Renker" <gerrit@erg.abdn.ac.uk>,
	"Ian McDonald" <ian.mcdonald@jandi.co.nz>,
	"Leandro Sales" <leandroal@gmail.com>,
	"Arnaldo Carvalho de Melo" <acme@redhat.com>,
	"DCCP Mailing
Return-path: <netdev-owner@vger.kernel.org>
Received: from gv-out-0910.google.com ([216.239.58.187]:52625 "EHLO
	gv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752537AbYKRRlM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Nov 2008 12:41:12 -0500
Received: by gv-out-0910.google.com with SMTP id e6so541884gvc.37
        for <netdev@vger.kernel.org>; Tue, 18 Nov 2008 09:41:09 -0800 (PST)
In-Reply-To: <20081118061414.GA4015@gerrit.erg.abdn.ac.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 18, 2008 at 7:14 PM, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> | The RFC uses an example of 1 msec scheduling and 0.1 msec RTT. However
> | what would be worse is devices on a LAN with 10 msec timer - e.g. two
> | embedded devices at home - I haven't done the maths but I think the
> | rate achievable would be quite low.
> If we use lower-resolution timers I think there should be a
> recommendation (in the Kconfig menu for instance) not to use
> low HZ values.
>
> Previously this was done as a build warning, but it is annoying if
> people do an allmodconfig and are not otherwise interested in DCCP.
>
Agree

> Do you think we could live with clamping the RTT to some sensible
> minimum, since on a local LAN the use of congestion control is
> questionable? I was thinking in the order of 0.5 ... 1msec.
>
I think that is a good idea - if 1 msec, and HZ = 1000 then we
wouldn't lose any transmission capability.

> | Thinking laterally there is another possible solution - something I
> | used way back in the 80s for another project - build your own
> | scheduler! We could set a high resolution timer to tick every 0.1 msec
> | and then use the coarse grained algorithm at that point....
> |
> So we have three possible options - timer-based (low/high), and your
> suggestion above. We can keep these variants open by spawning an
> experimental subtree which provides an alternative implementation, so
> that people could explore alternative algorithms, compare and send patches.
>
> For production use the low-resolution variant is the simplest and less
> expensive option, and it is good that there is consensus about it.
>
Yes - and with your RTT clamping then no need to do my idea around scheduler.

> In a discussion about two years ago there was another
> idea, doing away with the nofeedback timer, by checking the nofeedback
> time at the instant a packet is sent.
>
I think this is useful as reduces the amount of timers going off,
which reduces system load.

-- 
Web: http://wand.net.nz/~iam4/, http://www.jandi.co.nz
Blog: http://iansblog.jandi.co.nz
