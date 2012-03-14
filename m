From: Dave Taht <dave.taht@gmail.com>
Subject: Re: [PATCH] sch_sfq: revert dont put new flow at the end of flows
Date: Wed, 14 Mar 2012 06:07:57 +0000
Message-ID: <CAA93jw7mpV0pVN=7e2JNKBw7_Piax07P3sjC81Wbj36aPP42UA@mail.gmail.com>
References: <1327570722.8191.46.camel@probook>
	<1331697865.2456.19.camel@edumazet-laptop>
	<CAA93jw4kYqCWg424SXkrtQeg9bPfpfgH-x_7tjg=m8uxk_GNaA@mail.gmail.com>
	<1331701332.2456.25.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jdb@comx.dk, David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:49905 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756614Ab2CNGH6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Mar 2012 02:07:58 -0400
Received: by wibhj6 with SMTP id hj6so6574212wib.1
        for <netdev@vger.kernel.org>; Tue, 13 Mar 2012 23:07:57 -0700 (PDT)
In-Reply-To: <1331701332.2456.25.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 14, 2012 at 5:02 AM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le mercredi 14 mars 2012 =E0 04:52 +0000, Dave Taht a =E9crit :
>
>> I had some hope for a semi-random alternating queue
>>
>
> I spent some time implementing two queues, one for new flows, one for
> old flows. As soon as a new flow uses its initial quantum, its moved =
at
> the tail of 'old flows queue'.
>
> But I always could find a way to starve some flows, even adding some
> kind of persistence. Right now, as soon as we empty one flow, we forg=
et
> its history.
>
> Next packet coming will create a "new flow" with a full quantum credi=
t,
> even if we nearly consume all flow quantum in the last micro second.
>
> Thats definitely not a trivial problem.

I've expended brain cells on this too (nobody has any experience with h=
ead drop,
aqm managed queues!), and was unable to come up with a way of dealing w=
ith
the corner case of too many new streams inside of sfq's current archite=
cture.

But I gotta say that the overall effect of this on optimizing sparse st=
reams
(dns,dhcp,tcp syn,ra,other routing packets,gaming packets,etc) was pret=
ty
freaking amazing, and it nearly eliminated any need for classification =
and
prioritization, BE, and BK were enough.

Ah, well. The other stuff in 3.3 is really good, too.

Sometimes you win, sometimes you lose, sometimes... it rains.

>
>
>



--=20
Dave T=E4ht
SKYPE: davetaht
US Tel: 1-239-829-5608
http://www.bufferbloat.net
