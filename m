From: Egil Hjelmeland <privat@egil-hjelmeland.no>
Subject: Re: [PATCH net-next v2 07/10] net: dsa: lan9303: Added basic
 offloading of unicast traffic
Date: Thu, 27 Jul 2017 16:07:01 +0200
Message-ID: <04c8ba05-56ac-c207-6bfe-4d20162ba5c1@egil-hjelmeland.no>
References: <20170725161553.30147-1-privat@egil-hjelmeland.no>
 <20170725161553.30147-8-privat@egil-hjelmeland.no>
 <20170726172443.GR12049@lunn.ch>
 <19cbabee-a0e5-03f1-d2fa-eea3521311a8@egil-hjelmeland.no>
 <20170727133113.GB18666@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: corbet@lwn.net, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, davem@davemloft.net, kernel@pengutronix.de,
        linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170727133113.GB18666@lunn.ch>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 27. juli 2017 15:31, Andrew Lunn wrote:
>>> I think you are over-simplifying here. Say i have a layer 2 VPN and i
>>> bridge port 1 and the VPN? The software bridge still wants to do STP
>>> on port 1, in order to solve loops.
>>>
>>
>> Problem is that the mainline lan9303_separate_ports() does its
>> work by setting port 1 & 2 in STP BLOCKING state (and port 0 in
>> FORWARDING state). So my understanding is that it would break port
>> separation if LAN9303_SWE_PORT_STATE is written while the driver
>> is in the non-bridged state.
> 
> If the hardware cannot do it, that is a different matter. But if the
> hardware can do STP states per port, you should try to make use of it
> here.
> 

The HW does STP states per port, but not per pair of port.
I can set port 1 in learning, but I can not tell port 2
to ignore addresses learned on port 1. (Except by using VLAN).

Unless somebody can come up with an other way to implement the
port separation, I think this is how it has to be. I suppose
we don't want to break the port separation feature.


>> I thought the SW bridge would carry doing its STP work even if
>> there is a port_stp_state_set method on a DSA port?
> 
> It will, but it means you are dropping frames in software, adding
> extra load to the CPU, reducing the available bandwidth for the other
> port, etc.
> 

That is exactly the case with all traffic with the current mainline
driver.


>         Andrew
> 

Egil
