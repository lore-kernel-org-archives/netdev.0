From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [RFC] net: napi fix
Date: Thu, 13 Dec 2007 23:28:41 +0100
Message-ID: <4761B219.1030303@gmail.com>
References: <20071213134953.GA3806@ff.dom.local>	<20071213.055013.83963139.davem@davemloft.net>	<4761930C.3030504@gmail.com> <20071213.123727.224454625.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: auke-jan.h.kok@intel.com, gallatin@myri.com, joonwpark81@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jgarzik@pobox.com, shemminger@linux-foundation.org,
	jesse.brandeburg@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.185]:62815 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754152AbXLMWZV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2007 17:25:21 -0500
Received: by nf-out-0910.google.com with SMTP id g13so699290nfb.21
        for <netdev@vger.kernel.org>; Thu, 13 Dec 2007 14:25:19 -0800 (PST)
In-Reply-To: <20071213.123727.224454625.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote, On 12/13/2007 09:37 PM:
...

> For example, if we export the list handling widget into the ->poll()
> routines, god help the person who wants to change how the poll list is
> managed in net_rx_action() :-/

...I'm afraid I can't understand: I mean doing the same but without
passing this info with 'work == weight': if driver sends this info,
why it can't instead call something like napi_continue() with
this list_move_tail() (and probably additional local_irq_disable()/
enble() - but since it's unlikely()?) which looks much more readable,
and saves one whole unlikely if ()?

Jarek P.
