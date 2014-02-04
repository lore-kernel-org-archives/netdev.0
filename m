From: Mathias Kretschmer <mathias.kretschmer@fokus.fraunhofer.de>
Subject: Re: linux-3.14-rc1 & PACKET_QDISC_BYPASS : slow_path warning
Date: Tue, 4 Feb 2014 15:35:02 +0100
Message-ID: <52F0FA96.7090903@fokus.fraunhofer.de>
References: <52F01C97.20001@fokus.fraunhofer.de> <52F0E361.9000304@redhat.com> <52F0E771.8070904@fokus.fraunhofer.de> <52F0F86C.3050402@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	Felix Fietkau <nbd@openwrt.org>,
	Jesper Dangaard Brouer <jbrouer@redhat.com>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx-relay06-dus.antispameurope.com ([94.100.134.206]:54910 "EHLO
	mx-relay06-dus.antispameurope.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752629AbaBDOfU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Feb 2014 09:35:20 -0500
In-Reply-To: <52F0F86C.3050402@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/04/2014 03:25 PM, Daniel Borkmann wrote:
> On 02/04/2014 02:13 PM, Mathias Kretschmer wrote:
>> On 02/04/2014 01:56 PM, Daniel Borkmann wrote:
>>> On 02/03/2014 11:47 PM, Mathias Kretschmer wrote:
> ...
>>>> we are developing a wired/wireless MPLS switch. Currently the data plane runs in
>>>> user space using PF_PACKET sockets via RX_RING/TX_RING.
>>>>
>>>> We had hoped to test the PACKET_QDISC_BYPASS option since this seems to be the
>>>> proper optimization for our purposes.
>>>>
>>>> Unfortunately, we're seeing a 'slow path' warning for every packet that is being
>>>> sent out. With PACKET_QDISC_BYPASS disabled, no warnings are dumped. Hardware is
>>>> an older AMD Geode LX embedded board (ALiX).
>>>>
>>>> BTW, this happens while sending via a wireless (802.11) adhoc interface. Hence, it
>>>> might be an interaction with the ieee80211 sub system.
>>>
>>> Hm, so the WARN_ON() is triggered inside ath9k driver in relation to 802.11 QoS,
>>> and came in from commit 066dae93bdf ("ath9k: rework tx queue selection and fix
>>> queue stopping/waking"). We did the stress testing of that option for PF_PACKET
>>> on 10Gbit/s NICs. Seems to me you might be running into the same issue when using
>>> pktgen as it randomly or per round-robin selects tx queues as well? Not entirely
>>> sure how necessary this WARN_ON() is though, Felix? I think QDISC_BYPASS might not
>>> be the best option in your case, perhaps you will run into increased power usage
>>> in your NIC as a side-effect?
>>
>> I'm not familiar with the exact implementation details, but from the description
>> of this option, it seems to me that this is exactly what one would want to use if
>> the goal is to send an Ethernet frame out on a particular interface without any
>> further processing by the kernel.
>>
>> Why would this increase the power usage on the NIC ?  Due to a higher achievable
>> packet rate ?  That would be acceptable :)
>
> I'm not too familiar with the ieee80211 sub system, so I let Felix answer side
> effects and if actually the WARN_ON() is needed. ;) PACKET_QDISC_BYPASS is, as
> documented, designed for advanced pktgen resp. traffic generator like scenarios
> where you just sort of "brute force" packets to your NIC to stress test a remote
> machine for further analysis. I don't think it's very useful in your scenario
> when you have a wired/wireless MPLS switch, you rather might want to buffer/queue
> and therefore use qdisc layer instead.

Hm, I was hoping/assuming that we still get to use hardware queues, if provided by 
the driver. The main goal was to avoid any further PF_PACKET framework overhead.

If the WARN_ON() issue gets solved, we will revisit this option and evaluate its 
applicability.

Thanks,

Mathias
