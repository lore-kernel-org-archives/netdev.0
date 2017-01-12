From: Mason <slash.tmp@free.fr>
Subject: Re: Setting link down or up in software
Date: Thu, 12 Jan 2017 17:22:14 +0100
Message-ID: <75281de4-d50d-76fd-8de9-606001a4d93a@free.fr>
References: <75bd6df2-714a-2b9b-a0e3-f5574c295377@free.fr>
 <2044a26f-cf95-ac55-6265-ac76c3ca53f6@free.fr>
 <20170112152856.GL13033@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Mans Rullgard <mans@mansr.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Thibaud Cornic <thibaud_cornic@sigmadesigns.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5-g21.free.fr ([212.27.42.5]:37093 "EHLO smtp5-g21.free.fr"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750733AbdALQWb (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 12 Jan 2017 11:22:31 -0500
In-Reply-To: <20170112152856.GL13033@lunn.ch>
Content-Language: 
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/01/2017 16:28, Andrew Lunn wrote:

> Mason wrote:
> 
>> Here's an example of "Link is Down" printed when I set link up:
>>
>> At [   62.750220] I run ip link set dev eth0 down
>> Then leave the system idle for 10 minutes.
>> At [  646.263041] I run ip link set dev eth0 up
>> At [  647.364079] it prints "Link is Down"
>> At [  649.417434] it prints "Link is Up - 1Gbps/Full - flow control rx/tx"
> 
> Purely a guess, but when you up the interface, it starts auto
> negotiation. That often involves resetting the PHY. If the PHY has
> already once completed autoneg, e.g. because of the boot loader, it
> will be initially UP. The reset will put it DOWN, and then once
> autoneg is complete, it will be Up again.
> 
> Pure guess. Go read the code and see if i'm write.

Thanks for giving me some food for thought, although the net framework
is far from easy to navigate. (So I'm not sure "go read the code" will
take me anywhere in the short term.)

Whatever the reason for the symptoms I'm seeing, some kind of race
condition must be involved, because it occurs randomly.

Regards.
