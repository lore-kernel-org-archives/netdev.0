From: Roger Quadros <rogerq@ti.com>
Subject: Re: [PATCH v3 1/2] net: phy: Fix PHY AN done state machine for
 interrupt driven PHYs
Date: Fri, 31 Mar 2017 12:19:57 +0300
Message-ID: <b4a3eec9-a5a2-bbec-1cb2-917edfdca705@ti.com>
References: <1490180524-28675-1-git-send-email-rogerq@ti.com>
 <1490180524-28675-2-git-send-email-rogerq@ti.com>
 <078917ad-77a1-a722-1688-6203ae183a46@ti.com>
 <d536d55f-8f13-59f9-ca85-04f6ca88c811@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <andrew@lunn.ch>, <davem@davemloft.net>, <kyle.roeschley@ni.com>,
        <nsekhar@ti.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>,
        "stable # v4 . 9+" <stable@vger.kernel.org>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <d536d55f-8f13-59f9-ca85-04f6ca88c811@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Florian,

On 30/03/17 23:02, Florian Fainelli wrote:
> On 03/27/2017 04:59 AM, Roger Quadros wrote:
>> The Ethernet link on an interrupt driven PHY was not coming up if the
>> Ethernet cable was plugged before the Ethernet interface was brought up.
>>
>> The PHY state machine seems to be stuck from RUNNING to AN state
>> with no new interrupts from the PHY. So it doesn't know when the
>> PHY Auto-negotiation has been completed and doesn't transition to RUNNING
>> state with ANEG done thus netif_carrier_on() is never called.
>>
>> NOTE: genphy_config_aneg() will not restart PHY Auto-negotiation of
>> advertisement parameters didn't change.
>>
>> Fix this by scheduling the PHY state machine in phy_start_aneg().
>> There is no way of knowing in phy.c whether auto-negotiation was
>> restarted or not by the PHY driver so we just wait for the next
>> poll/interrupt to update the PHY state machine.
>>
>> Fixes: 3c293f4e08b5 ("net: phy: Trigger state machine on state change and not polling.")
>> Cc: stable <stable@vger.kernel.org> # v4.9+
>> Signed-off-by: Roger Quadros <rogerq@ti.com>
> 
> Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
> 
Thanks for the review, but there are a still few unanswered questions in the parallel thread.
Can you please clarify those first before this patch gets picked? Thanks.

cheers,
-roger
