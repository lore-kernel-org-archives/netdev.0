From: Arnd Hannemann <hannemann@nets.rwth-aachen.de>
Subject: Re: [PATCH][TCP]: simplify tcp_mark_lost_retrans()
Date: Wed, 07 Jan 2009 17:14:26 +0100
Message-ID: <4964D4E2.8050602@nets.rwth-aachen.de>
References: <alpine.DEB.2.00.0901071009000.6102@rhea>
 <Pine.LNX.4.64.0901071229160.27307@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-1.ms.rz.RWTH-Aachen.DE ([134.130.7.72]:55945 "EHLO
	mta-1.ms.rz.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758748AbZAGQOe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2009 11:14:34 -0500
In-reply-to: <Pine.LNX.4.64.0901071229160.27307@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ilpo J=E4rvinen schrieb:
> On Wed, 7 Jan 2009, Arnd Hannemann wrote:
>
>  =20
>> I noticed
>>    =20
>
> Good that somebody else is looking TCP code besides me... :-)
>  =20
Well I try hard... ;-)
>  =20
>> that in tcp_mark_lost_retrans the for-loop is only entered
>> if tcp_is_fack(tp) evaluates to true:
>>
>>           if (!tcp_is_fack(tp) || !tp->retrans_out ||
>>               !after(received_upto, tp->lost_retrans_low) ||
>>               icsk->icsk_ca_state !=3D TCP_CA_Recovery)
>>                   return;
>>
>> Therefore the following check in the for-loop seems to be redundant,
>> because it always evaluates to true:
>>
>>                      (tcp_is_fack(tp) ||
>>                       !before(received_upto,
>>                               ack_seq + tp->reordering * tp->mss_cac=
he))
>>
>> Did I miss something?
>>    =20
>
> It was just a left over from the RFC3517 SACK addition which added th=
at=20
> !tcp_is_fack(tp) there above. ...It would have been nice to have simi=
lar=20
> lost rexmit feature without FACK as well but calculating that wasn't=20
> trivial (or I didn't find that too trivial) and could end up being=20
> extremely expensive in case of large holes. (So I also left it there =
as=20
> sort of reminder).
>  =20
Perhaps it would be better to let the comments reflect
what you just said and remove the redundant check
anyway to reduce the dead code a newcomer has to understand ;-)
I would have included a patch for the comments, but as you have a
deeper understanding of the code it would probably
be better if you can do it.

Best regards,
Arnd



