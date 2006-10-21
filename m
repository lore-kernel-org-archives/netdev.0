From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH] e100_shutdown: netif_poll_disable hang
Date: Sat, 21 Oct 2006 10:54:02 -0700
Message-ID: <453A5EBA.5050701@intel.com>
References: <20061020182820.978932000@mvista.com> <453936E0.1010204@intel.com>	<45393B0B.8090301@intel.com> <87slhh1s90.fsf@brouette.noos.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Walker <dwalker@mvista.com>, Andrew Morton <akpm@osdl.org>,
	Jeff Garzik <jgarzik@pobox.com>, linux-kernel@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:56244 "EHLO mga09.intel.com")
	by vger.kernel.org with ESMTP id S2993143AbWJURzS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Oct 2006 13:55:18 -0400
To: Damien Wyart <damien.wyart@free.fr>
In-Reply-To: <87slhh1s90.fsf@brouette.noos.fr>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Damien Wyart wrote:
>>>> My machine annoyingly hangs while rebooting. I tracked it down to
>>>> e100-fix-reboot-f-with-netconsole-enabled.patch in 2.6.18-rc2-mm2
>>>> I review the changes and it seemed to be calling
>>>> netif_poll_disable one too many time. Once in e100_down(), and
>>>> again in e100_shutdown().
>>>> The second one in e100_shutdown() caused the hang. So this patch
>>>> removes it.
> 
> * Auke Kok <auke-jan.h.kok@intel.com> [061020 23:09]:
>> it doesn't even do harm to netif_poll_disable() twice as far as I can
>> see, as it merely calls test_and_set_bit(), which will instantly
>> succeed on the first attempt if the bit was already set.
> 
>> did this change actually fix it for you? I'm wondering if the
>> netif_carrier_off might not be the culprit here...
> 
> I can confirm the proposed original change of D. Walker fixed the
> problem for me. I did not test the change you proposed as a followup.

his change breaks something else (a reboot with netconsole, possibly suspend). Please 
give the latest version I sent a try. Daniel confirmed me that it works, but it's always 
nice to hear it from more people.

Thanks

Auke
