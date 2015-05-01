From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: Re: [PATCH 0/3] A few minor clean-ups to eth_type_trans
Date: Fri, 01 May 2015 08:34:20 -0700
Message-ID: <55439CFC.3090406@redhat.com>
References: <20150430214917.1798.49769.stgit@ahduyck-vm-fedora22> <20150430223510.GA13111@Alexeis-MBP.westell.com> <5542B6AF.9010602@gmail.com> <063D6719AE5E284EB5DD2968C1650D6D1CB2A3B6@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: David Laight <David.Laight@ACULAB.COM>,
	"'Alexander Duyck'" <alexander.duyck@gmail.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42119 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753699AbbEAPee (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 May 2015 11:34:34 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CB2A3B6@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/01/2015 04:30 AM, David Laight wrote:
> From: Alexander Duyck
>> Sent: 01 May 2015 00:12
> ...
>>> Only the comment 'ETH_P_802_3_MIN is aligned to 512' through me off.
>>> It's divisible by 256 that matters.
>> Yeah, it is 0x0600 hex so we can ignore the lower 8 bits, or in the case
>> of little-endian systems the upper 8 bits.  I think when I had
>> originally written the patch I was using a mask of 0xFE00, but then I
>> realized that all the compiler cared about is knowing which byte it is
>> supposed to compare against.
> Isn't the limit actually 1500 (0x5dc) not 1536 (0x600).
> Certainly the longest 8802.3 frame has a 'length' field of 1500
> followed by the 3 bytes LLC header and 1497 bytes of 'userdata'.
> (If you do ISO transport nothing is ever word aligned.)
>
> Whether any 'ethertypes' from 0x5dd to 0x5ff were ever allocated
> (and plausibly still in use) is a separate question.
> Some below 1500 were allocated.
>
> 	David

Actually it comes straight from the IEEE Std 802.3, sections 3.2.6. If 
the field value is less than or equal to 1500 (05DC hex), then the field 
is length.  If the field is greater than or equal to 1536 (0600 hex), 
then it is an Ethertype.  The region from 1501 to 1535 isn't really 
defined in the standard in terms of behavior, but then again if that 
value is used it likely isn't an 802.3 frame anyway. For the purposes of 
this check all we care about is the 802.3 Ethertypes which the standard 
says are at 0x600 and above.

- Alex
