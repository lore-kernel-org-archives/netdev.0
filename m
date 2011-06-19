From: Dominik Kaspar <dokaspar.ietf@gmail.com>
Subject: Re: Linux TCP's Robustness to Multipath Packet Reordering
Date: Sun, 19 Jun 2011 17:22:04 +0200
Message-ID: <BANLkTinueBFkVmR-Hd6d1Yojt+gsAV9PYw@mail.gmail.com>
References: <BANLkTimpgXCpweZKCihCQkLjSZw5zL4=Pg@mail.gmail.com>
	<BANLkTikjcd6ZAF5wH_8CKA_OCrfprGokmw@mail.gmail.com>
	<BANLkTikoQfbSxnJi_OR+N6sa5iVNcTO6Ug@mail.gmail.com>
	<201104271157.49386.carsten@wolffcarsten.de>
	<BANLkTimNC9DgWtkTTtjC_v0FsxzvBMsQGw@mail.gmail.com>
	<BANLkTi=i5ZftuL++ORuy=n_yM_futWYoZw@mail.gmail.com>
	<BANLkTinsHuP3XSSghfpYET=os9VcJ3FRDA@mail.gmail.com>
	<BANLkTin5dsubSjOhz3enOjubfVVk6uiNbQ@mail.gmail.com>
	<B35A6FDF-714A-4226-AFF4-D12ECCD4A152@comsys.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Alexander Zimmermann <alexander.zimmermann@comsys.rwth-aachen.de>,
	Yuchung Cheng <ycheng@google.com>,
	Carsten Wolff <carsten@wolffcarsten.de>,
	John Heffner <johnwheffner@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Lennart Schulte <Lennart.Schulte@comsys.rwth-aachen.de>,
	Arnd Hannemann <arnd@arndnet.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:46970 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754168Ab1FSPWG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jun 2011 11:22:06 -0400
Received: by iwn6 with SMTP id 6so575914iwn.19
        for <netdev@vger.kernel.org>; Sun, 19 Jun 2011 08:22:05 -0700 (PDT)
In-Reply-To: <B35A6FDF-714A-4226-AFF4-D12ECCD4A152@comsys.rwth-aachen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello again,

I have another question to Linux TCP and packet reordering. What
exactly happens, when a packet is so much delayed (but not causing a
timeout), that it gets overtaken by a retransmitted version of itself?
It seems to me that this results in "SACK reneging", but I don't
really understand why...

The simplified situation goes this:
- Segment A gets sent and very much delayed (but not causing RTO)
- Segments B, C, D cause dupACKs
- Segment A_ret is retransmitted and ACKed (sent over new path)
- Some more segments E, F, ... are sent and ACKed
- Segment A (the delayed one) arrives at the receiver.
- Now what exactly happens next...?

I use default Linux TCP (with sack=1, dsack=1, fack=1, timestamps=1,
...) and the above described series of events is cause why
transparently forwarding IP packets over multiple paths with RTTs of
10 and 100 milliseconds.

I'd appreciate your help - best regards,
Dominik
