From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next RFC 0/9] net: dsa: PTP timestamping for mv88e6xxx
Date: Thu, 28 Sep 2017 10:51:00 -0700
Message-ID: <8828c5c3-fe0f-c8d0-0a19-f173001de607@gmail.com>
References: <1506612341-18061-1-git-send-email-brandon.streiff@ni.com>
 <20170928173629.GD14940@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Richard Cochran <richardcochran@gmail.com>,
        Erik Hons <erik.hons@ni.com>
To: Andrew Lunn <andrew@lunn.ch>,
        Brandon Streiff <brandon.streiff@ni.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170928173629.GD14940@lunn.ch>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/28/2017 10:36 AM, Andrew Lunn wrote:
>> - Patch #3: The GPIO config support is handled in a very simple manner.
>>   I suspect a longer term goal would be to use pinctrl here.
> 
> I assume ptp already has the core code to use pinctrl and Linux
> standard GPIOs? What does the device tree binding look like? How do
> you specify the GPIOs to use?
> 
> What we want to avoid is defining an ABI now, otherwise it is going to
> be hard to swap to pinctrl later.
> 
>> - Patch #6: the dsa_switch pointer and port index is plumbed from
>>   dsa_device_ops::rcv so that we can call the correct port_rxtstamp
>>   method. This involved instrumenting all of the *_tag_rcv functions in
>>   a way that's kind of a kludge and that I'm not terribly happy with.
> 
> Yes, this is ugly. I will see if i can find a better way to do
> this. 

See my reply in patch 6, I may be missing something, but once
dst->rdcv() has been called, skb->dev points to the slave network device
which already contains the switch port and switch information in
dsa_slave_priv, so that should lift the need for asking the individual
taggers' rcv() callback to tell us about it.
-- 
Florian
