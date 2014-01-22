From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH] net/openvswitch: Remove the skb encapsulation mark after decapsulation
Date: Wed, 22 Jan 2014 10:02:54 -0800
Message-ID: <CAEP_g=9n5=a28-AOJYVt56OQLvO2X6nA+nVbOqhWEQK9jQqMGw@mail.gmail.com>
References: <1390403705-28690-1-git-send-email-ogerlitz@mellanox.com>
 <CAEP_g=9_8aPyve-obKCLo9ByFPvSNEtNBpaUKCw7X8Tcc3U1yA@mail.gmail.com> <CAJZOPZ+oRD=76JUELo51yZTTvjnc=4HYy0EPWtR1HH1CY870cA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Joseph Gasparakis <joseph.gasparakis@intel.com>,
	Pravin B Shelar <pshelar@nicira.com>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog134.obsmtp.com ([74.125.149.83]:37145 "HELO
	na3sys009aog134.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752310AbaAVSDP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jan 2014 13:03:15 -0500
Received: by mail-ig0-f175.google.com with SMTP id uq10so14577021igb.2
        for <netdev@vger.kernel.org>; Wed, 22 Jan 2014 10:03:14 -0800 (PST)
In-Reply-To: <CAJZOPZ+oRD=76JUELo51yZTTvjnc=4HYy0EPWtR1HH1CY870cA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 22, 2014 at 9:23 AM, Or Gerlitz <or.gerlitz@gmail.com> wrote:
> On Wed, Jan 22, 2014 at 7:02 PM, Jesse Gross <jesse@nicira.com> wrote:
>> On Wed, Jan 22, 2014 at 7:15 AM, Or Gerlitz <ogerlitz@mellanox.com> wrote:
>>> We must unset the skb encapsulation mark before injecting the
>>> decapsulated packet into ovs for the rest of its journey.
>>>
>>> This follows the practice set by 0afb166 "vxlan: Add capability of Rx
>>> checksum offload for inner packet" and the overall idea behind the
>>> skb encapsulation field.
>>>
>>> Cc: Joseph Gasparakis <joseph.gasparakis@intel.com>
>>> Cc: Pravin B Shelar <pshelar@nicira.com>
>>> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
>>
>> This should be in the common decapsulation code. It doesn't make sense
>> to do this here when we set the layer pointers, encap bit, etc. in
>> common code on transmit.
>
> well that's a bit problematic, since the code in the vxlan driver vxlan_rcv()
> which has the potential to be common refers to vxlan->dev-> which is
> irrelevant for ovs, thoughts?

Well, as I said before, I don't really see the value in the
NETIF_F_RXCSUM flag on a VXLAN device but in any case you could break
that if statement in half and move the part that doesn't refer to
vxlan->dev into common code.
