From: "Grant Likely" <grant.likely@secretlab.ca>
Subject: Re: [PATCH] phylib: add mdio-gpio bus driver (v2)
Date: Tue, 28 Oct 2008 07:08:06 -0600
Message-ID: <fa686aa40810280608q1c58e07cq7c5f2cc9feeb8ef6@mail.gmail.com>
References: <20081027105318.21923.24436.stgit@Programuotojas.82-135-208-232.ip.zebra.lt>
	 <20081027143734.GA13565@secretlab.ca> <4906C338.6010300@teltonika.lt>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.arm.linux.org.uk,
	linux-embedded@vger.kernel.org
To: "Paulius Zaleckas" <paulius.zaleckas@teltonika.lt>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.224]:25983 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752382AbYJ1NII (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2008 09:08:08 -0400
In-Reply-To: <4906C338.6010300@teltonika.lt>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 28, 2008 at 1:46 AM, Paulius Zaleckas
<paulius.zaleckas@teltonika.lt> wrote:
> Grant Likely wrote:
>> The IRQ array is fixed size.  You can add it to the mdio_gpio_info
>> structure and then just set the pointer here so that only one kzalloc
>> is needed.
>
> It can be put in mdio_gpio_info, but please note that mdio_gpio_info is
> allocated with kzalloc() and irq with kmalloc(), because there is no need
> to fill this array with zeros(see below).

Adding an additional 32 words to be zeroed in the mdio_gpio_info
kzalloc is considerably cheaper than doing an additional kmalloc.
Plus, once the array is zeroed it is then in the cache and so the
filling it with -1 also becomes cheaper.

g.

-- 
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
