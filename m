From: Neil Horman <nhorman@redhat.com>
Subject: Re: The ultimate TOE design
Date: Thu, 16 Sep 2004 07:37:16 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41497AEC.1010807@redhat.com>
References: <4148991B.9050200@pobox.com> <Pine.LNX.4.61.0409152102050.23011@fogarty.jakma.org> <4148A561.5070401@redhat.com> <ciaao4$crc$1@sea.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Wes Felter <wesley@felter.org>
In-Reply-To: <ciaao4$crc$1@sea.gmane.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Wes Felter wrote:
> Neil Horman wrote:
> 
>> Paul Jakma wrote:
>>
>>> On Wed, 15 Sep 2004, Jeff Garzik wrote:
>>>
>>>> Put simply, the "ultimate TOE card" would be a card with network 
>>>> ports, a generic CPU (arm, mips, whatever.), some RAM, and some 
>>>> flash.  This card's "firmware" is the Linux kernel, configured to 
>>>> run as a _totally indepenent network node_, with IP address(es) all 
>>>> its own.
>>>>
>>>> Then, your host system OS will communicate with the Linux kernel 
>>>> running on the card across the PCI bus, using IP packets (64K fixed 
>>>> MTU).
> 
> 
>>> The intel IXP's are like the above, XScale+extra-bits host-on-a-PCI 
>>> card running Linux. Or is that what you were referring to with 
>>> "<cards exist> but they are all fairly expensive."?
> 
> 
>> IBM's PowerNP chip was also very simmilar (a powerpc core with lots of 
>> hardware assists for DMA and packet inspection in the extended 
>> register area).  Don't know if they still sell it, but at one time I 
>> had heard they had booted linux on it.
> 
> 
> An IXP or PowerNP wouldn't work for Jeff's idea. The IXP's XScale core 
> and PowerNP's PowerPC core are way too slow to do any significant 
> processing; they are intended for control tasks like updating the 
> routing tables. All the work in the IXP or PowerNP is done by the 
> microengines, which have weird, non-Linux-compatible architectures.
> 
I didn't say the assist hardware wouldn't need an extra driver.  Its not 
100% free, as Jeff proposes, but the CPU portion of these designs is 
_sufficient_ to run linux, and a driver can be written to drive the 
remainder of these chips.  Its the combination that network device 
manufacturers design to today: A specialized chip to do L3/L2 forwarding 
at line rate over a large number of ports, and just enough general 
purpose CPU to manage the user interface, the forwarding hardware and 
any overflow forwarding that the forwarding hardware can't deal with 
quickly.
> To do 10 Gbps Ethernet with Jeff's approach, wouldn't you need a 5-10 
> GHz processor on the card? Sounds expensive.
> 
To handle port densities that are competing in the market today?  Yes, 
which as I mentioned earlier would price designs like this out of the 
market.  Jeffs idea is a nice one, but it doesn't really fit well with 
the hardware that networking equipment manufacturers are building today. 
  Take a look at Broadcoms StrataSwitch/StrataXGS lines, or Switchcores 
Xpeedium processors.  These are the sorts of things we have to work with 
.  They provide network stack offload in competitive port densities, but 
they aren't also general purpose processors.  They need a driver to 
massage their behavior into something more linux friendly.  If we could 
develop an infrastrucutre that made these chips easy to integrate into a 
  platform running linux, linux could quickly come to dominate a large 
portion of the network device space.

Neil

> Wes Felter - wesley@felter.org - http://felter.org/wesley/
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/


-- 
/***************************************************
  *Neil Horman
  *Software Engineer
  *Red Hat, Inc.
  *nhorman@redhat.com
  *gpg keyid: 1024D / 0x92A74FA1
  *http://pgp.mit.edu
  ***************************************************/
