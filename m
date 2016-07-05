From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCHv3 wl-drv-next 1/2] add basic register-field manipulation
 macros
Date: Tue, 5 Jul 2016 10:56:13 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D5F4F06BF@AcuExch.aculab.com>
References: <1467408409-24224-1-git-send-email-jakub.kicinski@netronome.com>
 <1467408409-24224-2-git-send-email-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"hannes@stressinduktion.org" <hannes@stressinduktion.org>,
	"nbd@nbd.name" <nbd@nbd.name>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: 'Jakub Kicinski' <jakub.kicinski@netronome.com>,
	"kvalo@codeaurora.org" <kvalo@codeaurora.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.186]:56007 "EHLO
	smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751427AbcGEK6K convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2016 06:58:10 -0400
In-Reply-To: <1467408409-24224-2-git-send-email-jakub.kicinski@netronome.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Kicinski
> Sent: 01 July 2016 22:27
> 
> C bitfields are problematic and best avoided.  Developers
> interacting with hardware registers find themselves searching
> for easy-to-use alternatives.  Common approach is to define
> structures or sets of macros containing mask and shift pair.
> Operations on the register are then performed as follows:
> 
>  field = (reg >> shift) & mask;
> 
>  reg &= ~(mask << shift);
>  reg |= (field & mask) << shift;
> 
> Defining shift and mask separately is tedious.  Ivo van Doorn
> came up with an idea of computing them at compilation time
> based on a single shifted mask (later refined by Felix) which
> can be used like this:
> 
>  #define REG_FIELD 0x000ff000
> 
>  field = FIELD_GET(REG_FIELD, reg);
> 
>  reg &= ~REG_FIELD;
>  reg |= FIELD_PUT(REG_FIELD, field);

My problem with these sort of 'helpers' is that they make it much harder
to read code unless you happen to know exactly what the helpers do.
Unexpected issues (like values being sign extended) can be hard to spot.

A lot of the time you can make things simpler by not doing the shifts
(ie define shifted constants).

	David
