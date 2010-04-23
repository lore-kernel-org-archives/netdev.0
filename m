From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] e100: expose broadcast_disabled as a module option
Date: Fri, 23 Apr 2010 15:02:07 -0700
Message-ID: <20100423150207.7969c9f6@nehalam>
References: <l2nb43bf5491004231314i13503c67yeccfc54bc1cae850@mail.gmail.com>
	<h2p9929d2391004231322r23528f32z8447a711a29e28ea@mail.gmail.com>
	<20100423135816.23f5861f@nehalam>
	<r2ob43bf5491004231403o64f8b88bsa9543d9910648d97@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, alexander.h.duyck@intel.com,
	peter.p.waskiewicz.jr@intel.com, john.ronciak@intel.com
To: Erwan Velu <erwanaliasr1@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:58423 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754751Ab0DWWC3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Apr 2010 18:02:29 -0400
In-Reply-To: <r2ob43bf5491004231403o64f8b88bsa9543d9910648d97@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 23 Apr 2010 23:03:59 +0200
Erwan Velu <erwanaliasr1@gmail.com> wrote:

> I first tried "ifconfig -broadcast" without any success, so I forced
> the driver to unset IFF_BROADCAST, the interface didn't showed anymore
> the BROADCAST option with ifconfig. But I didn't noticed any reduction
> in the amount of context/switches on my host.
> 
> I found the broadcast_disabled far more efficient when considering the
> cpu impact.

The point is that the driver can look at IFF_BROADCAST rather than having
module parameter. Module parameters are device driver specific and should
be avoid as much as possible in favor of general mechanism. This is a repeated
problem where users and vendors make special hooks that only work with their
driver, which makes life hard for other users and distribution providers.
