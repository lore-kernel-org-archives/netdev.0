From: sowmini varadhan <sowmini05@gmail.com>
Subject: Re: Scaling 'ip addr add' (was Re: What's the right way to use a
 *large* number of source addresses?)
Date: Wed, 28 May 2014 13:18:55 -0400
Message-ID: <CACP96tTVoHKrVJD+nX9=PpV-tk1CQ31=9bxdFeGUvDaJUrmkWA@mail.gmail.com>
References: <CACP96tRSpop=Sf58qE6TXeF+a-5nqfCj5d12bwD9WaYue_6_UA@mail.gmail.com>
	<1401241268.5367.266.camel@edumazet-glaptop2.roam.corp.google.com>
	<CACP96tRBiANHxXSFZ_w7eKwO_zWk_AZv-7CDJFLSP6+bZJLZ5g@mail.gmail.com>
	<1401284699.5367.268.camel@edumazet-glaptop2.roam.corp.google.com>
	<1401288533.5367.271.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	=?UTF-8?Q?Niels_M=C3=B6ller?= <nisse@southpole.se>,
	netdev <netdev@vger.kernel.org>, Jonas Bonn <jonas@southpole.se>,
	Jiri Pirko <jiri@resnulli.us>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:58221 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751675AbaE1RS5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 May 2014 13:18:57 -0400
Received: by mail-lb0-f174.google.com with SMTP id n15so5987063lbi.5
        for <netdev@vger.kernel.org>; Wed, 28 May 2014 10:18:55 -0700 (PDT)
In-Reply-To: <1401288533.5367.271.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 28, 2014 at 10:48 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:


> Following patch helps a lot
> (30 seconds to add 65536 addresses on lo interface instead of 52 seconds
> on my host)

I haven't had a chance to try out your patch yet (thanks for
the "dont do a del" caveat :-)) and I'm going to try it out now,
 but reading your info makes me
wonder- in this case all the addresses that are being added
are static Ipv4 addrs, i.e., they are clearly IFA_F_PERMANENT
addresses, so check_lifetime() should not have too much work
to do (other than to examine the ifa_flags and continue). So
why is this making such a big difference?

Alternatively, afaict check_lifetime() is only interested in
an !IFA_F_PERMANENT. So maybe __inet_insert_ifa should
only do the {inet_hash_insert(..); /* reset check_lifetime_work */}
when it added a !PERMANENT address? Would this break
something else? (I realize it may need more changes elsewhere,
if the PERMANENT flag is modified on the fly, I've not checked
for those yet)

--Sowmini
