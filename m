From: Philip Prindeville <philipp_subx@redfish-solutions.com>
Subject: Re: [PATCH v2 1/1] solos-pci: Fix regression introduced by newest
 firmware
Date: Sun, 20 Mar 2011 22:56:43 -0700
Message-ID: <4D86E89B.1060905@redfish-solutions.com>
References: <4D86AF4F.5010203@redfish-solutions.com>	<1300676496.26693.318.camel@localhost> <20110320.215704.193716335.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org,
	linux-atm-general@lists.sourceforge.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.redfish-solutions.com ([66.232.79.143]:56235 "EHLO
	mail.redfish-solutions.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751486Ab1CUF5D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Mar 2011 01:57:03 -0400
In-Reply-To: <20110320.215704.193716335.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/20/11 9:57 PM, David Miller wrote:
> From: Ben Hutchings<bhutchings@solarflare.com>
> Date: Mon, 21 Mar 2011 03:01:36 +0000
>
>> On Sun, 2011-03-20 at 18:52 -0700, Philip Prindeville wrote:
>>> The newest FPGA firmware on the Solos processors correctly signals
>>> carrier transitions, bitrate, etc.
>>>
>>> The driver previously ignored these messages, and the physical state
>>> was always ATM_PHY_SIG_UNKNOWN.
>>>
>>> Now that the board reports its state, we expose a bug whereby the
>>> transition from UNKNOWN to LOST causes us to release all VC's.
>>>
>>> We don't delete any VC's, but instead just send an indication of
>>> carrier change.
>>>
>>> Signed-off-by: Philip A Prindeville<philipp@redfish-solutions.com>
>>> ---
>>>
>>> --- a/drivers/atm/solos-pci.c	2011-03-20 15:27:40.000000000 -0600
>>> +++ b/drivers/atm/solos-pci.c	2011-03-20 16:32:11.000000000 -0600
>>> @@ -382,8 +382,10 @@ static int process_status(struct solos_c
>>>
>>>    	/* Anything but 'Showtime' is down */
>>>    	if (strcmp(state_str, "Showtime")) {
>>>    		atm_dev_signal_change(card->atmdev[port], ATM_PHY_SIG_LOST);
>>> +#if 0
>>>    		atm_dev_release_vccs(card->atmdev[port]);
>>> +#endif
>> Either remove it or don't.  #if 0 is for people without version control.
> Also, this would seem to break those using the older firmware.

It's not clear that dropping all VCs abruptly when carrier flapped was ever the right thing to do.

-Philip

