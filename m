From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 0/3] A few minor clean-ups to eth_type_trans
Date: Fri, 1 May 2015 11:30:33 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CB2A3B6@AcuExch.aculab.com>
References: <20150430214917.1798.49769.stgit@ahduyck-vm-fedora22>
 <20150430223510.GA13111@Alexeis-MBP.westell.com> <5542B6AF.9010602@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: 'Alexander Duyck' <alexander.duyck@gmail.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.194]:52337 "EHLO
	smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751193AbbEALc2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2015 07:32:28 -0400
In-Reply-To: <5542B6AF.9010602@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck
> Sent: 01 May 2015 00:12
...
> > Only the comment 'ETH_P_802_3_MIN is aligned to 512' through me off.
> > It's divisible by 256 that matters.
> 
> Yeah, it is 0x0600 hex so we can ignore the lower 8 bits, or in the case
> of little-endian systems the upper 8 bits.  I think when I had
> originally written the patch I was using a mask of 0xFE00, but then I
> realized that all the compiler cared about is knowing which byte it is
> supposed to compare against.

Isn't the limit actually 1500 (0x5dc) not 1536 (0x600).
Certainly the longest 8802.3 frame has a 'length' field of 1500
followed by the 3 bytes LLC header and 1497 bytes of 'userdata'.
(If you do ISO transport nothing is ever word aligned.)

Whether any 'ethertypes' from 0x5dd to 0x5ff were ever allocated
(and plausibly still in use) is a separate question.
Some below 1500 were allocated.

	David
