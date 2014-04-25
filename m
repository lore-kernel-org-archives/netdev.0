From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [RFC] sh_eth: use RNC mode for R8A7790
Date: Sat, 26 Apr 2014 03:55:33 +0400
Message-ID: <535AF5F5.1000703@cogentembedded.com>
References: <1396025185-7911-1-git-send-email-ben.dooks@codethink.co.uk> <5335DDC7.8040400@cogentembedded.com> <534BD8F9.5080105@codethink.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-sh@vger.kernel.org, magnus.damm@opensource.se,
	nobuhiro.iwamatsu.yj@renesas.com
To: Ben Dooks <ben.dooks@codethink.co.uk>, netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <534BD8F9.5080105@codethink.co.uk>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 04/14/2014 04:47 PM, Ben Dooks wrote:

>>> The current behaviour of the sh_eth driver is not to use the RNC bit
>>> for the receive ring. This means that every packet recieved is not only
>>> generating an IRQ but it also stops the receive ring DMA as well until
>>> the driver re-enables it after unloading the packet.

>>> This means that a number of the following errors are generated due to
>>> the receive packet FIFO overflowing due to nowhere to put packets:

>>>     net eth0: Receive FIFO Overflow

>>> Setting the RMCR_RNC configuration has so far been tested with an NFS
>>> root filesystem and the driver has not failed yet. It is not yet known
>>> why this is not set for R8A779x operation

>>     The reason is simple: it's not set on almost all 100 Mbs devices
>> except SH7757 (and most recently added R7S72100), so this was a matter
>> of copy-paste. I've had setting this bit on at least R-Car devices on my
>> aganda for some time but couldn't get to it yet.

>>> (Feedback on this issue or other testing is welcome)

>>     OK, I'll try it with netperf UDP test known to generate handful of
>> the aforementioned errors, when I have time.

>> WBR, Sergei

> Has anyone had time to look at this?

    OK, I've finally tried netperf and couldn't get it to reproduce these 
errors on any R-Car gen2 board. I was only able to reproduce this error on a 
new R8A7791 board during NFS boot, and applying the patch seems to have 
helped. So you can add my:

Tested-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

WBR, Sergei

