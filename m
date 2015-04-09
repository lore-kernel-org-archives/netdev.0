From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: Atheros 8035 PHY only works when at803x_config_init() is commented
 out
Date: Thu, 09 Apr 2015 12:00:42 -0700
Message-ID: <5526CC5A.1080504@gmail.com>
References: <5525571D.7060909@free.fr> <5525658D.7000709@gmail.com> <5526662C.8010509@free.fr> <5526806E.5020309@zonque.org> <55268EF3.7050301@free.fr> <5526993F.1010304@free.fr> <5526B608.2080504@gmail.com> <5526CA87.2070204@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Daniel Mack <daniel@zonque.org>, Mugunthan <mugunthanvnm@ti.com>,
	"David S. Miller" <davem@davemloft.net>,
	Matus Ujhelyi <ujhelyi.m@gmail.com>
To: Mason <slash.tmp@free.fr>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:34124 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753006AbbDITBi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2015 15:01:38 -0400
Received: by pdbqa5 with SMTP id qa5so105120968pdb.1
        for <netdev@vger.kernel.org>; Thu, 09 Apr 2015 12:01:38 -0700 (PDT)
In-Reply-To: <5526CA87.2070204@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/04/15 11:52, Mason wrote:
> Florian Fainelli wrote:
> 
>> Mason wrote:
>>
>>> Is speed auto-negotiation supposed to be complete when phy_init_hw exits?
>>
>> There is no such guarantee, and the PHY state machine is started later,
>> which will take care of auto-neg and other things.
> 
> That's what I thought.
> 
> So it's expected that many status bits will only change later.
> 
> You didn't comment on my patch. What's your take on it?

Quoting IEEE 802.3 section 2, paragprah 22.2.4.1:

"Resetting a PHY is accomplished by setting bit 0.15 to a logic one.
This action shall set the status and con-trol registers to their default
states. As a consequence this action may change the internal state of
the PHY
and the state of the physical link associated with the PHY. This bit is
self-clearing, and a PHY shall return a
value of one in bit 0.15 until the reset process is completed. A PHY is
not required to accept a write transac-
tion to the control register until the reset process is completed, and
writes to bits of the control register other
than 0.15 may have no effect until the reset process is completed. The
reset process shall be completed
within 0.5 s from the setting of bit 0.15.
"

So even though this is not extremely specific about whether or not doing
a RMW instead of W is accepted, considering that this resets the PHY
internal state, and the fact that there is a lack of clarify on whether
setting any bits other than 15 is going to fall under the "A PHY is not
required to accept a write transaction to the control register until the
reset process is completed" statement, setting only this bit at least
guarantees that you are back into your reset defaults.

As Daniel suggested, I would be looking for undocumented/proprietary
registers for reasons as to why your PHY is not working, in particular
(RG)MII tuning.
-- 
Florian
