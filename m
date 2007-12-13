From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] net: napi fix
Date: Thu, 13 Dec 2007 14:34:25 -0800 (PST)
Message-ID: <20071213.143425.142750733.davem@davemloft.net>
References: <4761930C.3030504@gmail.com>
	<20071213.123727.224454625.davem@davemloft.net>
	<4761B219.1030303@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: auke-jan.h.kok@intel.com, gallatin@myri.com, joonwpark81@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jgarzik@pobox.com, shemminger@linux-foundation.org,
	jesse.brandeburg@intel.com
To: jarkao2@gmail.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1765467AbXLMWe5@vger.kernel.org>
In-Reply-To: <4761B219.1030303@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Thu, 13 Dec 2007 23:28:41 +0100

> ...I'm afraid I can't understand: I mean doing the same but without
> passing this info with 'work == weight': if driver sends this info,
> why it can't instead call something like napi_continue() with
> this list_move_tail() (and probably additional local_irq_disable()/
> enble() - but since it's unlikely()?) which looks much more readable,
> and saves one whole unlikely if ()?

Because the poll list is private to net_rx_action() and we don't
want to expose implementation details like that to every
->poll() implementation.
