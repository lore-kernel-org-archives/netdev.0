From: Kevin Hilman <khilman@deeprootsystems.com>
Subject: Re: [PATCH 2/3] TI Davinci EMAC : add platform specific interrupt enable/disable logic.
Date: Wed, 18 Nov 2009 14:29:54 -0800
Message-ID: <87pr7fbh5p.fsf@deeprootsystems.com>
References: <1258537328-31527-1-git-send-email-srk@ti.com>
	<1258537328-31527-2-git-send-email-srk@ti.com>
	<1258537328-31527-3-git-send-email-srk@ti.com>
	<4B044628.9030701@boundarydevices.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sriramakrishnan <srk@ti.com>, netdev@vger.kernel.org,
	davinci-linux-open-source@linux.davincidsp.com
To: Troy Kisky <troy.kisky@boundarydevices.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f171.google.com ([209.85.222.171]:51163 "EHLO
	mail-pz0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751986AbZKRW3u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2009 17:29:50 -0500
Received: by pzk1 with SMTP id 1so1126715pzk.33
        for <netdev@vger.kernel.org>; Wed, 18 Nov 2009 14:29:56 -0800 (PST)
In-Reply-To: <4B044628.9030701@boundarydevices.com> (Troy Kisky's message of "Wed\, 18 Nov 2009 12\:08\:24 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Troy Kisky <troy.kisky@boundarydevices.com> writes:

> Sriramakrishnan wrote:
>> On certain SOCs, the EMAC controller is interfaced with a wrapper logic
>> for handling interrupts. This  patch implements a platform
>> specific hook to cater to platforms that require custom interrupt
>> handling logic
>> 
>> Signed-off-by: Sriramakrishnan <srk@ti.com>
>> Acked-by: Chaithrika U S <chaithrika@ti.com>
>> ---
>>  drivers/net/davinci_emac.c   |   11 +++++++++++
>>  include/linux/davinci_emac.h |    2 ++
>>  2 files changed, 13 insertions(+), 0 deletions(-)
>> 
>> diff --git a/drivers/net/davinci_emac.c b/drivers/net/davinci_emac.c
>> index 6aec8f5..81931f8 100644
>> --- a/drivers/net/davinci_emac.c
>> +++ b/drivers/net/davinci_emac.c
>> @@ -487,6 +487,9 @@ struct emac_priv {
>>  	struct mii_bus *mii_bus;
>>  	struct phy_device *phydev;
>>  	spinlock_t lock;
>> +	/*platform specific members*/
>> +	void (*wrapper_int_enable) (void);
>> +	void (*wrapper_int_disable) (void);
>
> Would platform_int_enable be more appropriate then wrapper_int_enable ?
>

Or just int_enable.  As it's being used through a private pointer,
it's clear that it's a wrapper.

Kevin
