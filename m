From: "Jan Altenberg" <jan@linutronix.de>
Subject: Re: can: c_can: TX echo
Date: Wed, 23 Mar 2011 14:54:07 +0100
Message-ID: <b7a5102e35a2afd04327d7b42da4e988.squirrel@www2.linutronix.de>
References: <16a340801622a96218c76dbbabc7a23f.squirrel@www.linutronix.de>
    <20110323085133.GB346@e-circ.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Jan Altenberg" <jan@linutronix.de>, bhupesh.sharma@st.com,
	wg@grandegger.com, b.spranger@linutronix.de, netdev@vger.kernel.org
To: "Kurt Van Dijck" <kurt.van.dijck@eia.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:45395 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754946Ab1CWNyK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Mar 2011 09:54:10 -0400
In-Reply-To: <20110323085133.GB346@e-circ.dyndns.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

>> So, we first invalidate the message object and afterwards we read
>> the DLC value from the msg_cntrl (which is 0 after invalidating the
>> message object) to account the TX bytes. So tx_bytes will always be
>> 0.  The fix should be easy, I think, we can just move
>> c_can_inval_msg_object to the end of that loop.
>
> IMO, it looks necessary to call c_can_inval_msg_object inside the if
> (), after it has been transmitted. Otherwise, if for some other (TX)
> reason you get in this loop, you may clear a pending transmission?
> Again, I haven't read this one's datasheet. I was familiar with its
> predecessor.

I tried to check, but the datasheet is a bit unclear regarding that
point ;-) My interpretation is, that c_can_inval_msg_object()
shouldn't affect the txrqst bit, but nevertheless calling it inside
the if() statement would make the code more readable.

I can prepare a patch, but I'd like to wait for Wolfgang's / Bupesh's
feedback.

Cheers,
        Jan


