From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: can: c_can: TX echo
Date: Wed, 23 Mar 2011 15:25:59 +0100
Message-ID: <4D8A02F7.7050607@grandegger.com>
References: <16a340801622a96218c76dbbabc7a23f.squirrel@www.linutronix.de>    <20110323085133.GB346@e-circ.dyndns.org> <b7a5102e35a2afd04327d7b42da4e988.squirrel@www2.linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Kurt Van Dijck <kurt.van.dijck@eia.be>, bhupesh.sharma@st.com,
	b.spranger@linutronix.de, netdev@vger.kernel.org
To: Jan Altenberg <jan@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:38720 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755524Ab1CWOXu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Mar 2011 10:23:50 -0400
In-Reply-To: <b7a5102e35a2afd04327d7b42da4e988.squirrel@www2.linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jan,

On 03/23/2011 02:54 PM, Jan Altenberg wrote:
> Hi,
> 
>>> So, we first invalidate the message object and afterwards we read
>>> the DLC value from the msg_cntrl (which is 0 after invalidating the
>>> message object) to account the TX bytes. So tx_bytes will always be
>>> 0.  The fix should be easy, I think, we can just move
>>> c_can_inval_msg_object to the end of that loop.

This means that "ifconfig" will report *0* TX Bytes!?

>> IMO, it looks necessary to call c_can_inval_msg_object inside the if
>> (), after it has been transmitted. Otherwise, if for some other (TX)
>> reason you get in this loop, you may clear a pending transmission?
>> Again, I haven't read this one's datasheet. I was familiar with its
>> predecessor.
> 
> I tried to check, but the datasheet is a bit unclear regarding that
> point ;-) My interpretation is, that c_can_inval_msg_object()
> shouldn't affect the txrqst bit, but nevertheless calling it inside
> the if() statement would make the code more readable.
> 
> I can prepare a patch, but I'd like to wait for Wolfgang's / Bupesh's
> feedback.

I'm following the discussion and as I'm not familiar with that chip, I'm
waiting for Bupesh's answer as well... before I start digging. You can
also have a look to the pch_can driver, which is C_CAN based as well.

Wolfgang.
