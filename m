From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 0/2] net: dsa: don't unmask port bitmaps
Date: Mon, 23 Oct 2017 17:54:13 -0700
Message-ID: <be302ef8-7f12-aaf1-5f68-c4de89c7d83d@gmail.com>
References: <20171023181731.7977-1-vivien.didelot@savoirfairelinux.com>
 <20171023211109.GA23689@lunn.ch>
 <87h8upeesg.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f169.google.com ([209.85.216.169]:44355 "EHLO
        mail-qt0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932170AbdJXAyS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2017 20:54:18 -0400
In-Reply-To: <87h8upeesg.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/23/2017 02:26 PM, Vivien Didelot wrote:
> Hi Andrew,
> 
> Andrew Lunn <andrew@lunn.ch> writes:
> 
>> On Mon, Oct 23, 2017 at 02:17:29PM -0400, Vivien Didelot wrote:
>>> DSA has several bitmaps to store the type of ports: cpu_port_mask,
>>> dsa_port_mask and enabled_port_mask. But the code is inconsistently
>>> unmasking them.
>>>
>>> The legacy code tries to unmask cpu_port_mask and dsa_port_mask but
>>> skips enabled_port_mask.
>>>
>>> The new bindings unmasks cpu_port_mask and enabled_port_mask but skips
>>> dsa_port_mask.
>>>
>>> In fact there is no need to unmask them because we are in the error
>>> path, and they won't be used after. Instead of fixing the unmasking,
>>> simply remove them.
>>
>> I'm not looked at the code, travelling and don't have time.
> 
> heu, ok.
> 
>> What happens if the failure is -PROBE_DEFERRED, and it tried again
>> later. Will these masks be set back to 0? Or will they retain the old
>> values? I think there is supposed to be symmetry here, so that we undo
>> what we did, and so the next time we try again, we start from a good
>> state.

In case of probe deferral, you get the full probe function to exit with
an error, and that usually involves freeing the recently allocated
dsa_switch instance, and then allocating a new one when probe is
re-entered, so that should not be a problem.

> 
> The type of a port is a static information parsed either from device
> tree or from platform data. Thus there is no symmetry needed here.
> 
> The fact that the unmasking of these bitmaps is currently erroneous also
> shows that it is unnecessary.

As much as I would like to see this being symmetrical here, as Vivien
points out, this does not appear to be the case because of missing code,
and it does not seem to solve a particular problem in being symmetrical.
-- 
Florian
