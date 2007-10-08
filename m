From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH][E1000E] some cleanups
Date: Mon, 08 Oct 2007 15:40:44 -0700
Message-ID: <470AB1EC.2080000@intel.com>
References: <1191174077.6165.11.camel@localhost>	 <47028351.7090509@intel.com>  <1191417498.4357.23.camel@localhost> <1191773723.4394.31.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:7072 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751866AbXJHWk5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Oct 2007 18:40:57 -0400
In-Reply-To: <1191773723.4394.31.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> Ok, here you go; the explanation is below. This is from net-2.6.24 of
> early this AM. I saw a patch you posted that is derived from Krishna;
> although it hasnt showed up in the tree - i have considered those
> changes and this patch adds a little more optimization in case of
> errors.
> 
> I will send you a patch to kill LLTX the sooner this shows up somewhere.


thanks.

My biggest problem with the patch as you sent it that it's a tonload of changes
and no implicit benefit immediately as I can see. I would really have to see the
LLTX change as well to make a wellfounded decision whether it is the right thing
to go and overhaul this part of the driver or not :)

I'm not particularly against the changes per se though.

so please, if needed offlist send me those LLTX changes as well.

Auke

> 
> On Wed, 2007-03-10 at 09:18 -0400, jamal wrote:
> 
>> The cleanup is to break up the code so it is functionally more readable
>> from a perspective of the 4 distinct parts in ->hard_start_xmit():
>>
>> a) packet formatting (example: vlan, mss, descriptor counting, etc.)
>> b) chip-specific formatting
>> c) enqueueing the packet on a DMA ring
>> d) IO operations to complete packet transmit, tell DMA engine to chew
>> on, tx completion interrupts, set last tx time, etc.
>>
>> Each of those steps sitting in different functions accumulates state
>> that is used in the next steps. cb stores this state because it a
>> scratchpad the driver owns. You could create some other structure and
>> pass it around the iteration, but why waste more bytes.
> 
