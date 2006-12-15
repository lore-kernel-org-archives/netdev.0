From: Alex Romosan <romosan@sycorax.lbl.gov>
Subject: Re: 2.6.20-rc1 sky2 problems (regression?)
Date: Thu, 14 Dec 2006 17:04:01 -0800
Message-ID: <87mz5qnf5q.fsf@sycorax.lbl.gov>
References: <87psammchi.fsf@sycorax.lbl.gov>
	<20061214133023.0b266d8e@freekitty> <87odq6azel.fsf@sycorax.lbl.gov>
	<20061214144734.03300fa6@freekitty> <87zm9qkqsj.fsf@sycorax.lbl.gov>
	<20061214153146.52d5de40@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sycorax.lbl.gov ([128.3.5.196]:3239 "EHLO sycorax.lbl.gov"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932559AbWLOBEF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Dec 2006 20:04:05 -0500
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20061214153146.52d5de40@freekitty> (message from Stephen
	Hemminger on Thu, 14 Dec 2006 15:31:46 -0800)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger <shemminger@osdl.org> writes:

> If this is repeatable... and mac_pause is always one then the
> problem is hardware flow control.  I saw bugs before in the bus
> interface where it would not resume on unaligned buffer, but
> that was on receive.

i tried to switch over to the latest vendor driver but unfortunately
it doesn't work with kernel 2.6.19+. it still uses CHECKSUM_HW which
looks like it was replaced by CHECKSUM_PARTIAL and CHECKSUM_COMPLETE
was also added. i think i can replace CHECKSUM_HW in the marvell
driver with CHECKSUM_PARTIAL, except for a couple of places where i
i am not sure what i am supposed to do. the first instance it says (i
am kind of paraphrasing here since i am copying from the screen and
not cutting and pasting):

/** does the HW need to evaluate checksum for TCP or UDP packets?
if (pMessage->ip_summed == CHECKSUM_HW)

maybe this needs to be replace with CHECKSUM_PARTIAL. the second one

/** TCP checksum offload
if ((pSKPacket->pMbuf->ip_summed == CHECKSUM_HW) &&
(SetOpcodePacketFlag == SK_TRUE)

i wonder if this is supposed to be CHECKSUM_COMPLETE

if you have any suggestions, i'll appreciate it.

--alex--

-- 
| I believe the moment is at hand when, by a paranoiac and active |
|  advance of the mind, it will be possible (simultaneously with  |
|  automatism and other passive states) to systematize confusion  |
|  and thus to help to discredit completely the world of reality. |
