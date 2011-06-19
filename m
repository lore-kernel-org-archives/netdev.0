From: Dominik Kaspar <dokaspar.ietf@gmail.com>
Subject: Re: Linux TCP's Robustness to Multipath Packet Reordering
Date: Sun, 19 Jun 2011 18:25:47 +0200
Message-ID: <BANLkTi=SdhEnyad8keUO30LsNKFNvw6AoA@mail.gmail.com>
References: <BANLkTimpgXCpweZKCihCQkLjSZw5zL4=Pg@mail.gmail.com>
	<BANLkTikjcd6ZAF5wH_8CKA_OCrfprGokmw@mail.gmail.com>
	<BANLkTikoQfbSxnJi_OR+N6sa5iVNcTO6Ug@mail.gmail.com>
	<201104271157.49386.carsten@wolffcarsten.de>
	<BANLkTimNC9DgWtkTTtjC_v0FsxzvBMsQGw@mail.gmail.com>
	<BANLkTi=i5ZftuL++ORuy=n_yM_futWYoZw@mail.gmail.com>
	<BANLkTinsHuP3XSSghfpYET=os9VcJ3FRDA@mail.gmail.com>
	<BANLkTin5dsubSjOhz3enOjubfVVk6uiNbQ@mail.gmail.com>
	<B35A6FDF-714A-4226-AFF4-D12ECCD4A152@comsys.rwth-aachen.de>
	<BANLkTinueBFkVmR-Hd6d1Yojt+gsAV9PYw@mail.gmail.com>
	<C040825C-480A-46C6-AF32-76D90717BA06@comsys.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, Yuchung Cheng <ycheng@google.com>,
	Carsten Wolff <carsten@wolffcarsten.de>,
	John Heffner <johnwheffner@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Lennart Schulte <Lennart.Schulte@comsys.rwth-aachen.de>,
	Arnd Hannemann <arnd@arndnet.de>
To: Alexander Zimmermann <alexander.zimmermann@comsys.rwth-aachen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:56059 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751482Ab1FSQZs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jun 2011 12:25:48 -0400
Received: by iyb12 with SMTP id 12so1382077iyb.19
        for <netdev@vger.kernel.org>; Sun, 19 Jun 2011 09:25:47 -0700 (PDT)
In-Reply-To: <C040825C-480A-46C6-AF32-76D90717BA06@comsys.rwth-aachen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Alexander,

Ah... the receiver DSACKs the "original" packet. However, the sender
already received an ACK for its retransmission and advances SND.UNA.
When the DSACK finally arrives, it is actually outside of the SND.UNA
- SND.NXT range, which causes the DSACK to trigger "SACK reneging".
Did I get that right? :-)

Cheers,
Dominik

On Sun, Jun 19, 2011 at 5:38 PM, Alexander Zimmermann
<alexander.zimmermann@comsys.rwth-aachen.de> wrote:
> Hi,
>
> Am 19.06.2011 um 17:22 schrieb Dominik Kaspar:
>
>> Hello again,
>>
>> I have another question to Linux TCP and packet reordering. What
>> exactly happens, when a packet is so much delayed (but not causing a
>> timeout), that it gets overtaken by a retransmitted version of itself?
>> It seems to me that this results in "SACK reneging", but I don't
>> really understand why...
>
> in theory, you can detect this case with a combination of DSACK
> and timestamps. However, in practice a reordering delay greater than
> RTT will likely case an RTO (see RFC4653). IMO, if you have an packet
> reordering with an delay greater that the RTT, you have much more problems
> that SACK reneging
>
>>
>> The simplified situation goes this:
>> - Segment A gets sent and very much delayed (but not causing RTO)
>> - Segments B, C, D cause dupACKs
>> - Segment A_ret is retransmitted and ACKed (sent over new path)
>> - Some more segments E, F, ... are sent and ACKed
>> - Segment A (the delayed one) arrives at the receiver.
>> - Now what exactly happens next...?
>
> Receiver sends a DSACK
>
>>
>> I use default Linux TCP (with sack=1, dsack=1, fack=1, timestamps=1,
>> ...) and the above described series of events is cause why
>> transparently forwarding IP packets over multiple paths with RTTs of
>> 10 and 100 milliseconds.
>>
>> I'd appreciate your help - best regards,
>> Dominik
>
> //
> // Dipl.-Inform. Alexander Zimmermann
> // Department of Computer Science, Informatik 4
> // RWTH Aachen University
> // Ahornstr. 55, 52056 Aachen, Germany
> // phone: (49-241) 80-21422, fax: (49-241) 80-22222
> // email: zimmermann@cs.rwth-aachen.de
> // web: http://www.umic-mesh.net
> //
>
>
