From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH 12/23] e1000: Maybe stop TX if not enough free descriptors
Date: Tue, 19 Sep 2006 16:26:12 -0700
Message-ID: <45107C94.9020503@intel.com>
References: <20060919172623.4605.56860.stgit@gitlost.site>	<20060919172859.4605.60855.stgit@gitlost.site>	<45104719.9080708@pobox.com>	<20060919125019.316d3790@localhost.localdomain>	<451056D2.4080909@pobox.com> <20060919135910.1afb7f24@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>, netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:27964 "EHLO mga02.intel.com")
	by vger.kernel.org with ESMTP id S1750781AbWISX1i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2006 19:27:38 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060919135910.1afb7f24@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> On Tue, 19 Sep 2006 16:45:06 -0400
> Jeff Garzik <jgarzik@pobox.com> wrote:
> 
>> looks OK except for the tasklet, which may starve if the lock is being 
>> held upon entry
>>
>>
> 
> Why would the tasklet starve anymore than NAPI?
> Worst case, the transmitters fill the ring completely and have to
> wait for the tasklet to clean up.
> 
> Maybe it would be better to always to Tx cleanup in tasklet even with
> NAPI. Then the NAPI poll flow control would be used only for Rx.
> As it stands, if receiver gets swamped, the poll doesn't get run often,
> so the transmitter cleanup doesn't get run. A tasklet has the advantage
> of eliminating the need for adapter->tx_queue_lock as well.

I gave it a spin and it looks horrible with NAPI - the box almost freezes up 
with even 2 clients. Minor nitpick: you forgot to delete a spin_lock_irqsave() 
call but gcc would have spotted that for you. Unsurprisingly it's more stable 
without NAPI.

I'm unsure (not enough knowlege) why you would prefer to remove lltx - care to 
enlighten me?

Cheers,

Auke
