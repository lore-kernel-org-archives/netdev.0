From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: SMP code / network stack
Date: Thu, 10 Jan 2008 10:31:58 -0800
Message-ID: <4786649E.60502@intel.com>
References: <1199973946.29856.27.camel@vglwks010.vgl2.office.vaioni.com> <20080110154548.4b78ec7c.dada1@cosmosbay.com> <1199978819.29856.43.camel@vglwks010.vgl2.office.vaioni.com> <20080110174657.GL22437@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Arnaldo Carvalho de Melo <acme@redhat.com>,
	Jeba Anandhan <jeba.anandhan@vaioni.com>,
	Eric Dumazet <dada1@cosmosbay.com>, netdev@vger.kernel.org,
	matthew.hattersley@vaioni.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:21376 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753781AbYAJScq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jan 2008 13:32:46 -0500
In-Reply-To: <20080110174657.GL22437@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Arnaldo Carvalho de Melo wrote:
> Em Thu, Jan 10, 2008 at 03:26:59PM +0000, Jeba Anandhan escreveu:
>> Hi Eric,
>> Thanks for the reply. I have one more doubt. For example, if we have 2
>> processor and 4 ethernet cards. Only CPU0 does all work through 8 cards.
>> If we set the affinity to each ethernet card as CPU number, will it be
>> efficient?.
>>
>> Will this be default behavior?
>>
>> # cat /proc/interrupts 
>>            CPU0       CPU1       
>>   0:   11472559   74291833    IO-APIC-edge  timer
>>   2:          0          0          XT-PIC  cascade
>>   8:          0          1    IO-APIC-edge  rtc
>>  81:          0          0   IO-APIC-level  ohci_hcd
>>  97: 1830022231        847   IO-APIC-level  ehci_hcd, eth0
>>  97: 3830012232        847   IO-APIC-level  ehci_hcd, eth1
>>  97: 5830052231        847   IO-APIC-level  ehci_hcd, eth2
>>  97: 6830032213        847   IO-APIC-level  ehci_hcd, eth3

another thing to try: if you don't need usb2 support, remove the ehci_hcd module -
this will give a slight less overhead servicing irq's in your system.

I take it that you have no MSI support in these ethernet cards?

Auke
