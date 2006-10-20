From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH] e100_shutdown: netif_poll_disable hang
Date: Fri, 20 Oct 2006 14:09:31 -0700
Message-ID: <45393B0B.8090301@intel.com>
References: <20061020182820.978932000@mvista.com> <453936E0.1010204@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Walker <dwalker@mvista.com>, Andrew Morton <akpm@osdl.org>,
	Jeff Garzik <jgarzik@pobox.com>, linux-kernel@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:9373 "EHLO mga01.intel.com")
	by vger.kernel.org with ESMTP id S1423236AbWJTVLX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2006 17:11:23 -0400
To: Auke Kok <auke-jan.h.kok@intel.com>
In-Reply-To: <453936E0.1010204@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Auke Kok wrote:
> Daniel Walker wrote:
>> My machine annoyingly hangs while rebooting. I tracked it down
>> to e100-fix-reboot-f-with-netconsole-enabled.patch in 2.6.18-rc2-mm2
>>
>> I review the changes and it seemed to be calling netif_poll_disable
>> one too many time. Once in e100_down(), and again in e100_shutdown().
>>
>> The second one in e100_shutdown() caused the hang. So this patch
>> removes it.

it doesn't even do harm to netif_poll_disable() twice as far as I can see, as it merely 
calls test_and_set_bit(), which will instantly succeed on the first attempt if the bit 
was already set.

did this change actually fix it for you? I'm wondering if the netif_carrier_off might 
not be the culprit here...

Auke
