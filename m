From: Egil Hjelmeland <privat@egil-hjelmeland.no>
Subject: Re: [RFC net-next] net: dsa: lan9303 Cpu port and ARL
Date: Mon, 23 Oct 2017 16:27:20 +0200
Message-ID: <ee8528e2-6a52-9ba0-4c96-bc83868ac6f2@egil-hjelmeland.no>
References: <20171023113506.13600-1-privat@egil-hjelmeland.no>
 <20171023125849.GE6740@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aibo.runbox.com ([91.220.196.211]:37708 "EHLO aibo.runbox.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751315AbdJWO1i (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 23 Oct 2017 10:27:38 -0400
In-Reply-To: <20171023125849.GE6740@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for the response, Andrew!

On 23. okt. 2017 14:58, Andrew Lunn wrote:
>>   #include "dsa_priv.h"
>> +#include "../../drivers/net/dsa/lan9303.h"
> 
> Don't do that. Export the needed parts in an include file in
> include/linux.
> 

Do you mean moving struct definitions from drivers/net/dsa/lan9303.h to 
a include/linux/lan9303.h? That would be like 80% of
drivers/net/dsa/lan9303.h. I am a bit surprised that is deemed better
than the slightly ugly include.

Or do you have other suggestions?

One possibility could be to have lan9303_tx_use_arl() in
drivers/net/dsa/lan9303-core.c. But it has to be exported, and can
not be inlined.

It is also possible to replace the  chip->is_bridged term with:

   struct dsa_switch *ds = dp->ds;
   if (!dsa_to_port(ds, 1)->bridge_dev)
               return false;
   if (dsa_to_port(ds, 1)->bridge_dev != dsa_to_port(ds,2)->bridge_dev)
               return false;

But it feels silly to duplicate that calculation in the data path.


> Otherwise, i think your approach is O.K.
> 
> 	   Andrew
> 

Egil
