From: Andrea G Forte <andreaf@cs.columbia.edu>
Subject: Re: primary and secondary ip addresses
Date: Fri, 17 Dec 2004 10:10:29 -0500
Message-ID: <41C2F6E5.5010607@cs.columbia.edu>
References: <41912F7A.6000408@redhat.com> <200412161153.51251.hasso@estpak.ee> <Pine.LNX.4.61.0412161103320.30452@filer.marasystems.com> <200412161302.42357.hasso@estpak.ee>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Henrik Nordstrom <hno@marasystems.com>,
	Harald Welte <laforge@gnumonks.org>,
	Neil Horman <nhorman@redhat.com>, linux-net@vger.kernel.org,
	netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: Hasso Tepper <hasso@estpak.ee>
In-Reply-To: <200412161302.42357.hasso@estpak.ee>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Yes, using the same concept used in Junos would make things much easier. 
On top of this, when I change the primary IP, it takes about 500ms to 
see the change applied which is critical for real time applications. 
Using more than one primary IP would solve this as well.
Also it seems that if I have a primary address and a secondary one 
(alias), even though I make the primary address invalid (trying to force 
the kernel to use the secondary first), the kernel still tries the 
primary first regardless of its validity (I set the primary IP to  0.0.0.0).
Anybody has any comments about this?
Can anyone point out to me where is the code for primary/secondary IPs 
in the kernel?

Thanks a lot,
Andrea


Hasso Tepper wrote:

>Henrik Nordstrom wrote:
>  
>
>>On Thu, 16 Dec 2004, Hasso Tepper wrote:
>>    
>>
>>>And why I can't even choose which address is primary?
>>>      
>>>
>>It is the first you add in a subnet.
>>    
>>
>
>Yes, but to change the primary I have remove old primary (and therefore all 
>secondaries) and assign new primary to the interface and then all 
>secondaries etc. I can't just tell "make this address which is secondary at 
>the moment, primary".
>
>  
>
>>>Primary
>>>=======
>>>
>>>Configure this address to be the primary address of the protocol on
>>>the interface. If the logical unit has more than one address, the
>>>primary address is used by default as the source address when packets
>>>originate from the interface and the destination does not indicate
>>>the subnet (ie. multicast destination for example).
>>>      
>>>
>>This is what the primary addresses is used for, indirectly via the
>>automatically created route entries.
>>    
>>
>
>No. There is only one primary address per interface and it is used if 
>destination address doesn't indicate which source address to use. Ie. if 
>packet is sent over eth1 to the address 224.0.0.6 and eth1 has addresses 
>192.168.0.1/24 and 10.10.10.1/24 which one choose for source address?
>
>  
>
>>>Preferred
>>>=========
>>>
>>>Configure this address to be the preferred address on the interface.
>>>If you configure more than one address on the same subnet, the
>>>preferred source address is chosen by default as the source address
>>>when you originate packets to destinations on the subnet.
>>>      
>>>
>>What is the difference from primary here?
>>    
>>
>
>This has same meaning as primary in the Linux. There is as many preferred 
>addresses on the interfaces as there is subnets - every subnet has one 
>preferred address. Preferred aadress is used if next hop indicates subnet - 
>if packet is sent to the 192.168.0.2, 192.168.0.1 is used as source; if 
>packet is sent to the 10.10.10.28, 10.10.10.1 is used as source.
>
>
>  
>

