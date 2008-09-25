From: Ivan Vecera <ivecera@redhat.com>
Subject: Re: [PATCH] r8169: read MAC address from EEPROM on init
Date: Thu, 25 Sep 2008 13:04:58 +0200
Message-ID: <48DB705A.6040301@redhat.com>
References: <48D25BA2.6070008@redhat.com>	 <Pine.LNX.4.64.0809182235550.4742@wrl-59.cs.helsinki.fi>	 <48D3A381.1080500@redhat.com>	 <Pine.LNX.4.64.0809210100020.16838@wrl-59.cs.helsinki.fi>	 <48D9FE65.40709@redhat.com>	 <20080924211021.GB9746@electric-eye.fr.zoreil.com>	 <48DB5C04.9050308@redhat.com> <1222338250.8641.61.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: 7bit
Cc: =?ISO-8859-2?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Netdev <netdev@vger.kernel.org>,
	Edward Hsu <edward_hsu@realtek.com.tw>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Ben Hutchings <bhutchings@solarflare.com>,
	Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:38335 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753104AbYIYLFZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Sep 2008 07:05:25 -0400
In-Reply-To: <1222338250.8641.61.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings wrote:
> On Thu, 2008-09-25 at 11:38 +0200, Ivan Vecera wrote:
>> Francois Romieu wrote:
>>> Ivan Vecera <ivecera@redhat.com> :
>>> [...]
>>>> OK :-), I hope the patch below is finally the right one.
>>> My approval ratings won't surge today.
>>>
>>> Is there a specific explanation for the 10 us delay ?
>>>
>>> Realtek's 8168 / 8169 / 8101 drivers all use a (wildly copy'pasted ?)
>>> 10 ms delay. I would not mind a 10 ms sleep.
>> 'pci_vpd_pci22_wait' uses 100us(10x10us delay) for reading, there is 1ms
>> (100x10us delay) in my patch, because 100us max. delay was too little for
>> Realtek.
> 
> If the maximum delay there is too short, it should be increased.  As
> I've said before, I picked a timeout that worked for me in the absence
> of any time limit in the PCI specification.  I thought Stephen Hemminger
> had modified it to work for sky2 but it looks like that change was
> blocked by quibbling about how best to poll.
> 
> Ben.
Yes, I did the same for r8169. 100us total was too short so I increase
total possible delay to 1 ms. Some net drivers use infinite loop with
flag testing but I think it isn't good approach and 10ms hard delay is
a little bit long.

Ivan.

