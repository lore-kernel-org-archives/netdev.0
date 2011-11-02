From: =?ISO-8859-1?Q?David_T=E4ht?= <dave.taht@gmail.com>
Subject: Re: Quick Fair Queue scheduler maturity and examples
Date: Wed, 02 Nov 2011 11:05:43 +0100
Message-ID: <4EB115F7.5070203@gmail.com>
References: <CAN==1RowdZ094pkOA3vbs-fd3g-NSABqaGC3WXSPL8Y0Lqg+fQ@mail.gmail.com> <1319716772.2601.26.camel@edumazet-laptop> <CAN==1Rq+WEcezLPNPNug2V11nftDkm2=aRKw95u_R8OPGxG72g@mail.gmail.com> <1319731732.2601.40.camel@edumazet-laptop> <1319732832.2601.43.camel@edumazet-laptop> <CAN==1Ro3Va7JHfOoENu=gJqfaktrqLvpo3NWV8=ZB9OKtyfeYQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060507090002020507020401"
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	bloat <bloat@lists.bufferbloat.net>
To: Karel Rericha <karel@maxtel.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:45478 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754312Ab1KBKFs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2011 06:05:48 -0400
Received: by wyh15 with SMTP id 15so1280559wyh.19
        for <netdev@vger.kernel.org>; Wed, 02 Nov 2011 03:05:47 -0700 (PDT)
In-Reply-To: <CAN==1Ro3Va7JHfOoENu=gJqfaktrqLvpo3NWV8=ZB9OKtyfeYQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------060507090002020507020401
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8bit

(Example elided, see thread on netdev)

On 11/02/2011 10:36 AM, Karel Rericha wrote:
> 2011/10/27 Eric Dumazet<eric.dumazet@gmail.com>:
> Thanks for example Eric. But it only added more confusion to me now 
> :-) I was under impression (and read somewhere) that QFQ is non work 
> conserving scheduler so I can use it more or less like HTB or HFSC to 
> set bandwidth constraints to flows. But from this example (and from 
> sources/patches/papers I try not to pretend I fully understand) it 
> looks to me like some multiqueue scheduler with arbitrary number of 
> queues and ability to arbitrary assign flows to this queues. So some 
> sort of fair division of available bandwidth to flows without 
> arbitrary bandwidth caps to these flows. 
This is what I want! It may not be what you want...
> I really dont see what is non work conserving here :-S Please save my 
> soul and enlighten me because I am at dead end now :-)

I initially had great hope for QFQ as I've been saying (mostly 
privately) that "PFIFO_FAST must die" for over a year now. What to 
replace it with is a rather large question, but I felt a start would be 
to adopt some FQ algorithm. Over the last couple weeks I read all the 
papers regarding DRR and QFQ and also poked into the source code and 
like you, am seriously un-enlightened.

I think eric's example is misleading as he divided up the queues by 
bandwidth, rather than flow, in the first tier of his tc hierarchy. 
useful as a test...

That said, buried in one of the papers on QFQ is the item that it isn't 
entirely fair queuing, as it has a maximum MSS of 5, rather than 1. 
Still that would be an improvement over diffserv based classification in 
the general case, and being somewhat bursty actually helps with 802.11n 
packet aggregation (at present).

Anyway, I've built QFQ into the latest cerowrt and am building it for 
another machine, and will try to come up with good ways to configure it 
this week.

My use cases are different than yours, however.

On a wireless STA (a laptop) - FQ all flows originating from that box. 
This would, for example, jump a DNS packet, ping, or TCP SYN attempt - 
to near the beginning of the transmit buffer while another elephant flow 
is taking place.

On the AP, FQ across the clients (so aggregation works better and 
bittorrent is suppressed), and FQ within each flow from/to that client 
(so as to reduce head of line blocking and have better performance for 
things like dns/ping/etc) - this would apply to the internal wireless 
and wired interfaces. As for the gateway interface, FQ across 
originating clients as well (but far more stuff than that needs to happen)

Haven't a clue how to do any of that right at all, at present. Clues 
wanted. I emailed one of the authors of QFQ for a clue, no reply as yet....

PS Also along the way whilst poking into that source code I found that 
there was already a fifo_drop_head tc queue type, which strikes me as 
almost useful for VO and VI wireless queues...

-- 
Dave Täht


--------------060507090002020507020401
Content-Type: text/x-vcard; charset=utf-8;
 name="dave_taht.vcf"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="dave_taht.vcf"

begin:vcard
fn;quoted-printable:Dave T=C3=A4ht
n;quoted-printable:T=C3=A4ht;Dave
email;internet:dave.taht@gmail.com
tel;home:1-239-829-5608
tel;cell:0638645374
x-mozilla-html:FALSE
version:2.1
end:vcard


--------------060507090002020507020401--
