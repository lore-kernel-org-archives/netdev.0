From: David Greaves <david@dgreaves.com>
Subject: Re: 2.6.6 e1000 NETDEV WATCHDOG: eth0: transmit timed out
Date: Fri, 18 Jun 2004 22:28:53 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40D35E95.50104@dgreaves.com>
References: <40CDD68C.8070509@dgreaves.com>	<20040615155111.26d6b809@dell_ss3.pdx.osdl.net>	<40D0280B.2030308@dgreaves.com>	<Pine.LNX.4.60.0406180953240.1089@jlaas2.data.slu.se>	<20040618111124.3a2681b5@dell_ss3.pdx.osdl.net>	<40D337FA.1080404@dgreaves.com> <20040618141629.0edd9766@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jens Laas <jens.laas@data.slu.se>, "Glick, Kevin" <kevin.glick@intel.com>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Venkatesan, Ganesh" <ganesh.venkatesan@intel.com>
In-Reply-To: <20040618141629.0edd9766@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

OK
Thanks for the pointers and time Stephen, much appreciated :)

Ganesh and Jens - you said you'd like to keep this on-list so Stephen 
let's ensure your reply is archived...


David


Stephen Hemminger wrote:

>It will be up to Intel (Genesh et al) to look at this.
>
>
>On Fri, 18 Jun 2004 19:44:10 +0100
>David Greaves <david@dgreaves.com> wrote:
>
>  
>
>>Stephen Hemminger wrote:
>>
>>    
>>
>>>To get to the root of these problems, could you:
>>>
>>>* Give full lspci -v output for the boards in question.
>>> 
>>>
>>>      
>>>
>>ash:
>>00:07.0 Ethernet controller: Intel Corp.: Unknown device 1076
>>        Subsystem: Intel Corp.: Unknown device 1176
>>        Flags: bus master, 66Mhz, medium devsel, latency 32, IRQ 11
>>        Memory at e3020000 (32-bit, non-prefetchable) [size=128K]
>>        Memory at e3000000 (32-bit, non-prefetchable) [size=128K]
>>        I/O ports at b400 [size=64]
>>        Expansion ROM at <unassigned> [disabled] [size=128K]
>>        Capabilities: [dc] Power Management version 2
>>        Capabilities: [e4] PCI-X non-bridge device.
>>        Capabilities: [f0] Message Signalled Interrupts: 64bit+ 
>>Queue=0/0 Enable-
>>
>>    
>>
>
>  
>
>>Jun 18 19:38:18 ash kernel: eth0: may be hung last tx was 2457 ticks
>>
>>    
>>
>
>
>This means the code that in the e1000 watchdog is seeing the stuck board.
>The driver then calls netif_stop_queue which seems odd.
>
>  
>
>>Jun 18 19:38:20 ash kernel: eth0: may be hung last tx was 4457 ticks
>>Jun 18 19:38:22 ash kernel: eth0: may be hung last tx was 6457 ticks
>>Jun 18 19:38:24 ash kernel: eth0: may be hung last tx was 8457 ticks
>>Jun 18 19:38:26 ash kernel: NETDEV WATCHDOG: eth0: transmit timed out 
>>after 5000 j
>>iffies
>>Jun 18 19:38:26 ash kernel: eth0: transmit timeout from queuing
>>Jun 18 19:38:26 ash kernel: eth0: may be hung last tx was 10457 ticks
>>Jun 18 19:38:26 ash kernel: eth0: state=0x7 transmit ring size=4096 
>>count=256 to_u
>>se=66 to_clean=59
>>    
>>
>
>The state bits show:
>	XOFF - stopped (but that was done in e1000_watchdog)
>	START - board is running
>	PRESENT - board is present.
>That looks okay, but what was the state in the e1000 watchdog??
>
>  
>
