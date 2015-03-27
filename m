From: Boris Brezillon <boris.brezillon@free-electrons.com>
Subject: Re: [PATCH 3/4] net/macb: fix capabilities configuration
Date: Sat, 28 Mar 2015 00:02:35 +0100
Message-ID: <20150328000235.30337361@bbrezillon>
References: <cover.1427469791.git.nicolas.ferre@atmel.com>
	<bd7194896b4e4517a7675ae02fe7bed01f19a02d.1427469791.git.nicolas.ferre@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>,
	<linux-kernel@vger.kernel.org>,
	Cyrille Pitchen <cyrille.pitchen@atmel.com>,
	<monstr@monstr.eu>, <michal.simek@xilinx.com>, <punnaia@xilinx.com>
To: Nicolas Ferre <nicolas.ferre@atmel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from down.free-electrons.com ([37.187.137.238]:53303 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751850AbbC0XCu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Mar 2015 19:02:50 -0400
In-Reply-To: <bd7194896b4e4517a7675ae02fe7bed01f19a02d.1427469791.git.nicolas.ferre@atmel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Nicolas,

On Fri, 27 Mar 2015 16:34:11 +0100
Nicolas Ferre <nicolas.ferre@atmel.com> wrote:

> Capabilities configuration by macb_configure_caps() was moved far too late by
> 421d9df0628b (net/macb: merge at91_ether driver into macb driver) which would
> lead to badly configured hardware.

Indeed, the macb_configure_caps function is called a bit too late,
but ...

> So, move this function to early probe and modify its prototype to re-gain its
> original behavior.
> DT data retrieval is also moved to simplify the probe code flow.

... I'm not happy with these changes.
I tried to keep  specific init steps of macb and at91_ether separated
and you're moving macb_configure_caps call (not required on at91_ether
HW) into macb_probe (the common probe part).

How about moving macb_configure_caps a bit earlier in the macb_init
function [1] ?

Best Regards,

Boris

[1]http://code.bulix.org/8gyi6b-88141

-- 
Boris Brezillon, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com
