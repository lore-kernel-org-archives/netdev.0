From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [Patch RFC net-next] net: usb: r8152: Fix rx_bytes/tx_bytes to
 include FCS
Date: Thu, 18 May 2017 10:00:36 -0700
Message-ID: <b020ca48-d19a-9281-ee8a-d29038ee2b96@gmail.com>
References: <1495052615-14360-1-git-send-email-andrew@lunn.ch>
 <286d107e-2380-f8e9-3edf-c949707ea235@gmail.com>
 <20170518150925.GB707@lunn.ch>
 <20170518.112256.671702749693595449.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, hayeswang@realtek.com,
        mario_limonciello@dell.com
To: David Miller <davem@davemloft.net>, andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:37217 "EHLO
        mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933350AbdERRAm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 May 2017 13:00:42 -0400
Received: by mail-wm0-f46.google.com with SMTP id d127so59330456wmf.0
        for <netdev@vger.kernel.org>; Thu, 18 May 2017 10:00:42 -0700 (PDT)
In-Reply-To: <20170518.112256.671702749693595449.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/18/2017 08:22 AM, David Miller wrote:
> From: Andrew Lunn <andrew@lunn.ch>
> Date: Thu, 18 May 2017 17:09:25 +0200
> 
>> Since these are software counters, they can be consistent. From a
>> practical point of view, i doubt they ever will all be consistent,
>> there are simply too many drivers to test and change if
>> needed. However, for the ones somebody cares about, they can be made
>> consistent.
>>
>> I care about r8152, and would like to make it consistent with asix,
>> dsa, e1000e.
> 
> No objection from me for making software counters consistent.
> 

No objection for me as well, but I think we need to agree on what these
software counters represent, since there are several cases:

- BQL cares about bytes sent on the wire, so that should not include
pre/appended descriptors nor the FCS (nor the Ethernet preamble),
tx_bytes should be equivalent to that

- if we don't include the FCS on transmit, why should we include it on
receive? rx_bytes should have the same rules as tx_bytes: no
status/descriptor bytes, no FCS etc.
-- 
Florian
