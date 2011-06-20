From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: Linux TCP's Robustness to Multipath Packet Reordering
Date: Mon, 20 Jun 2011 13:42:45 +0300 (EEST)
Message-ID: <alpine.DEB.2.00.1106201336450.17529@wel-95.cs.helsinki.fi>
References: <BANLkTimpgXCpweZKCihCQkLjSZw5zL4=Pg@mail.gmail.com> <BANLkTikjcd6ZAF5wH_8CKA_OCrfprGokmw@mail.gmail.com> <BANLkTikoQfbSxnJi_OR+N6sa5iVNcTO6Ug@mail.gmail.com> <201104271157.49386.carsten@wolffcarsten.de> <BANLkTimNC9DgWtkTTtjC_v0FsxzvBMsQGw@mail.gmail.com>
 <BANLkTi=i5ZftuL++ORuy=n_yM_futWYoZw@mail.gmail.com> <BANLkTinsHuP3XSSghfpYET=os9VcJ3FRDA@mail.gmail.com> <BANLkTin5dsubSjOhz3enOjubfVVk6uiNbQ@mail.gmail.com> <B35A6FDF-714A-4226-AFF4-D12ECCD4A152@comsys.rwth-aachen.de> <BANLkTinueBFkVmR-Hd6d1Yojt+gsAV9PYw@mail.gmail.com>
 <C040825C-480A-46C6-AF32-76D90717BA06@comsys.rwth-aachen.de> <BANLkTi=SdhEnyad8keUO30LsNKFNvw6AoA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Alexander Zimmermann <alexander.zimmermann@comsys.rwth-aachen.de>,
	Netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>,
	Carsten Wolff <carsten@wolffcarsten.de>,
	John Heffner <johnwheffner@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Lennart Schulte <Lennart.Schulte@comsys.rwth-aachen.de>,
	Arnd Hannemann <arnd@arndnet.de>
To: Dominik Kaspar <dokaspar.ietf@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:50046 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751139Ab1FTKmr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2011 06:42:47 -0400
In-Reply-To: <BANLkTi=SdhEnyad8keUO30LsNKFNvw6AoA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 19 Jun 2011, Dominik Kaspar wrote:

> Ah... the receiver DSACKs the "original" packet. However, the sender
> already received an ACK for its retransmission and advances SND.UNA.
> When the DSACK finally arrives, it is actually outside of the SND.UNA
> - SND.NXT range, which causes the DSACK to trigger "SACK reneging".
> Did I get that right? :-)

Where did you get this idea of reneging?!? Reneging has nothing to do with 
DSACKs, instead it is only detected if the cumulative ACK stops to such 
boundary where the _next_ segment is SACKed (i.e., some reason the 
receiver "didn't bother" to cumulatively ACK for that too). ...That 
certainly does not happen (ever) for out of window DSACKs.

-- 
 i.
