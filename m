From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: bridge vs. bonding/pause frames (was: Forward EAPOL...)
Date: Fri, 1 Jul 2011 19:59:29 +0200
Message-ID: <BANLkTin_rCS1bJFRhAEGhE0+skFxbrE5_Q@mail.gmail.com>
References: <BANLkTi=goXU4SpP6dxX9C+YeLcVMEkcKHw@mail.gmail.com>
 <20110628202200.GB2121496@jupiter.n2.diac24.net> <BANLkTim1owW7iMS3hgKhm7DzTzE4X-jxHA@mail.gmail.com>
 <20110628210434.GD2121496@jupiter.n2.diac24.net> <BANLkTikN_TPPcyywVT5W9CrGAFJX8qQiyQ@mail.gmail.com>
 <20110628214637.GE2121496@jupiter.n2.diac24.net> <BANLkTi=4-xYNyaBOzeL04VioK8D0Q8secg@mail.gmail.com>
 <20110629163423.1d73b0ef@nehalam.ftrdhcpuser.net> <20110701101625.GB3988422@jupiter.n2.diac24.net>
 <BANLkTimjnP87CAA7JVAe5hqeP08Hd7766g@mail.gmail.com> <20110701151626.GC2613105@jupiter.n2.diac24.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	Nick Carter <ncarter100@gmail.com>, netdev@vger.kernel.org,
	davem@davemloft.net
To: David Lamparter <equinox@diac24.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:46952 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756486Ab1GAR7u convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2011 13:59:50 -0400
Received: by qwk3 with SMTP id 3so1709130qwk.19
        for <netdev@vger.kernel.org>; Fri, 01 Jul 2011 10:59:49 -0700 (PDT)
In-Reply-To: <20110701151626.GC2613105@jupiter.n2.diac24.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

W dniu 1 lipca 2011 17:16 u=BFytkownik David Lamparter
<equinox@diac24.net> napisa=B3:
> On Fri, Jul 01, 2011 at 04:58:56PM +0200, Micha=B3 Miros=B3aw wrote:
> [...]
>> > We _MUST_NOT_ pass bonding frames in any case, but we
>> > currently do that if STP is off. (cf. my earlier patch 1/2)
>>
>> If you use linux box as a (invisible) L2 network tap, then you want =
to
>> pass everything in the hub mode (including LACP/whatever).
>
> We must not do that by default, this breaks bridges with bonding devi=
ces
> as ports. I'm actively band-aiding that problem with ebtables on one =
of
> my boxes currently.
>
> How about I change "stp_forward_802local" to "forward_802local" and i=
t
> gets 3 values like:
> - 0 (default) behave like a switch, if STP is on then drop all 16
> =A0groups, if STP is off then drop :01 and :02
> - 1 forward regular groups - drop :01 and :02, forward everything els=
e
> - 2 forward everything ("invisible tap mode")
> optional:
> - -1 drop all 16 groups even if STP is off (not needed, can be done w=
ith
> =A0ebtables...)
>
> btw, since the drivers should eat up pause frames, you're not a fully
> invisible L2 tap anyway.

If -1 can be done with ebtables what is different for 0 and 1 cases?

Another idea: you could make this a 16-bit bitmap (bit per group) x2
(STP vs non-STP) - that would cover all uses with the same amount of
code.

Best Regards,
Micha=B3 Miros=B3aw
