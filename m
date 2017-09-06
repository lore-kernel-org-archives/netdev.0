From: Mason <slash.tmp@free.fr>
Subject: Re: [PATCH net] Revert "net: phy: Correctly process PHY_HALTED in
 phy_stop_machine()"
Date: Wed, 6 Sep 2017 16:55:20 +0200
Message-ID: <927413e9-4f1f-963c-2d3a-5a88de2eac9e@free.fr>
References: <1504140569-2063-1-git-send-email-f.fainelli@gmail.com>
 <f4bb5ac8-dae8-c0af-7aa6-e546fc0783fa@sigmadesigns.com>
 <a75691d9-c22a-9b89-2cce-604315062739@gmail.com>
 <d54d0555-c448-741c-eb63-5a773bed5a30@free.fr>
 <7b1c1dc9-b6e3-a1bd-2e36-474946741a79@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Marc Gonzalez <marc_gonzalez@sigmadesigns.com>,
        David Daney <ddaney.cavm@gmail.com>,
        netdev <netdev@vger.kernel.org>,
        Geert Uytterhoeven <geert+renesas@glider.be>,
        David Miller <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>, Mans Rullgard <mans@mansr.com>,
        Thibaud Cornic <thibaud_cornic@sigmadesigns.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5-g21.free.fr ([212.27.42.5]:19542 "EHLO smtp5-g21.free.fr"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932682AbdIFOzl (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 6 Sep 2017 10:55:41 -0400
In-Reply-To: <7b1c1dc9-b6e3-a1bd-2e36-474946741a79@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 31/08/2017 21:18, Florian Fainelli wrote:

> On 08/31/2017 12:09 PM, Mason wrote:
> 
>> 1) nb8800_link_reconfigure() calls phy_print_status()
>> which prints the "Link down" and "Link up" messages
>> to the console. With the patch reverted, nothing is
>> printed when the link goes down, and the result is
>> random when the link comes up. Sometimes, we get
>> down + up, sometimes just up.
> 
> Nothing printed when you bring down the network interface as a result of
> not signaling the link down, there is a small nuance here.

Let me first focus on the "Link down" message.

Do you agree that such a message should be printed when the
link goes down, not when the link comes up?

Perhaps the issue is that the 2 following cases need to be
handled differently:
A) operator sets link down on the command-line
B) asynchronous event makes link go down (peer is dead, cable is cut, etc)

In B) the PHY state machine keeps on running, and eventually
calls adjust_link()

In A) the driver calls phy_stop() and phy_disconnect() and
therefore adjust_link() will not be called?

Regards.
