From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 1/8] [TCP]: Uninline tcp_set_state
Date: Thu, 17 Jan 2008 13:41:21 +0100
Message-ID: <p73myr4bp5a.fsf@bingen.suse.de>
References: <12001308173969-git-send-email-ilpo.jarvinen@helsinki.fi>
	<12001308171262-git-send-email-ilpo.jarvinen@helsinki.fi>
	<20080112130355.74c39ae7@deepthought>
	<Pine.LNX.4.64.0801140858040.31652@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	Netdev <netdev@vger.kernel.org>
To: =?iso-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:38723 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751061AbYAQMlX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2008 07:41:23 -0500
In-Reply-To: <Pine.LNX.4.64.0801140858040.31652@kivilampi-30.cs.helsinki.fi>
 ("Ilpo =?iso-8859-1?Q?J=E4rvinen=22's?= message of "Mon\, 14 Jan 2008
 09\:20\:26 +0200 \(EET\)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi> writes:
>
> Besides, it not always that obvious that gcc is able to determine "th=
e
> constant state", considering e.g., the complexity in the cases with
> tcp_rcv_synsent_state_process, tcp_close_state, tcp_done. In such cas=
es
> uninlining should be done and gcc is probably not able to mix both ca=
ses
> nicely for a single function?

I think it would be cleanest to completely unswitch the function=20
and split into tcp_set_closed()  / tcp_set_established() / tcp_other_st=
ate()=20
called by the callers directly.

That would probably lose the state trace, but I never found=20
that useful for anything.

-Andi
