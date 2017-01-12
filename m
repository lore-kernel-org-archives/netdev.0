From: Mason <slash.tmp@free.fr>
Subject: Re: Setting link down or up in software
Date: Thu, 12 Jan 2017 16:16:49 +0100
Message-ID: <2044a26f-cf95-ac55-6265-ac76c3ca53f6@free.fr>
References: <75bd6df2-714a-2b9b-a0e3-f5574c295377@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Mans Rullgard <mans@mansr.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Thibaud Cornic <thibaud_cornic@sigmadesigns.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5-g21.free.fr ([212.27.42.5]:17475 "EHLO smtp5-g21.free.fr"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750720AbdALPRE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 12 Jan 2017 10:17:04 -0500
In-Reply-To: <75bd6df2-714a-2b9b-a0e3-f5574c295377@free.fr>
Content-Language: 
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/01/2017 14:05, Mason wrote:

> I'm wondering what are the semantics of calling
> 
> 	ip link set dev eth0 down
> 
> I was expecting that to somehow instruct the device's ethernet driver
> to shut everything down, have the PHY tell the peer that it's going
> away, maybe even put the PHY in some low-power mode, etc.
> 
> But it doesn't seem to be doing any of that on my HW.
> 
> So what exactly is it supposed to do?
> 
> 
> And on top of that, I am seeing random occurrences of
> 
> 	nb8800 26000.ethernet eth0: Link is Down
> 
> Sometimes it is printed immediately.
> Sometimes it is printed as soon as I run "ip link set dev eth0 up" (?!)
> Sometimes it is not printed at all.
> 
> I find this erratic behavior very confusing.
> 
> Is it the symptom of some deeper bug?

Here's an example of "Link is Down" printed when I set link up:

At [   62.750220] I run ip link set dev eth0 down
Then leave the system idle for 10 minutes.
At [  646.263041] I run ip link set dev eth0 up
At [  647.364079] it prints "Link is Down"
At [  649.417434] it prints "Link is Up - 1Gbps/Full - flow control rx/tx"

I think whether I set up the PHY to use interrupts or polling
does have an influence on the weirdness I observe.

AFAICT, changing the interface flags is done in dev_change_flags
which calls __dev_change_flags and __dev_notify_flags

Is one of these supposed to call the device driver through a
callback at some point?

How/when is the phy_state_machine notified of the change in
interface flags?

Regards.
