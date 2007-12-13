From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [RFC] net: napi fix
Date: Thu, 13 Dec 2007 23:58:59 +0100
Message-ID: <4761B933.4030008@gmail.com>
References: <4761930C.3030504@gmail.com>	<20071213.123727.224454625.davem@davemloft.net>	<4761B219.1030303@gmail.com> <20071213.143425.142750733.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: auke-jan.h.kok@intel.com, gallatin@myri.com, joonwpark81@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jgarzik@pobox.com, shemminger@linux-foundation.org,
	jesse.brandeburg@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.187]:44928 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757904AbXLMWz0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2007 17:55:26 -0500
Received: by nf-out-0910.google.com with SMTP id g13so707613nfb.21
        for <netdev@vger.kernel.org>; Thu, 13 Dec 2007 14:55:24 -0800 (PST)
In-Reply-To: <20071213.143425.142750733.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote, On 12/13/2007 11:34 PM:

> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Thu, 13 Dec 2007 23:28:41 +0100
> 
>> ...I'm afraid I can't understand: I mean doing the same but without
>> passing this info with 'work == weight': if driver sends this info,
>> why it can't instead call something like napi_continue() with
>> this list_move_tail() (and probably additional local_irq_disable()/
>> enble() - but since it's unlikely()?) which looks much more readable,
>> and saves one whole unlikely if ()?
> 
> Because the poll list is private to net_rx_action() and we don't
> want to expose implementation details like that to every
> ->poll() implementation.

So, it seems 'we' failed e.g. exposing napi_complete()...
OK, no offense, I'll only mention at the end that there is
always a possibility to redefine such a function to {} with any
change of implementation.

Jarek P.
