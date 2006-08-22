From: Jon Wikne <wikne@cheetah.uio.no>
Subject: Re: sky2 driver - large files upload problem
Date: Tue, 22 Aug 2006 11:43:28 +0200
Message-ID: <44EAD1C0.6080701@cheetah.uio.no>
References: <44E9A9E0.20106@cheetah.uio.no>	<44E9B28C.9050207@gentoo.org>	<44E9C153.1010300@cheetah.uio.no>	<20060821095116.1b7f725d@localhost.localdomain>	<44EA2DD7.9060605@cheetah.uio.no> <20060821163645.0e1acfb6@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Daniel Drake <dsd@gentoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.4]:22435 "EHLO pat.uio.no")
	by vger.kernel.org with ESMTP id S1751386AbWHVJni (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2006 05:43:38 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060821163645.0e1acfb6@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> On Tue, 22 Aug 2006 00:04:07 +0200
> Jon Wikne <wikne@cheetah.uio.no> wrote:
> 
> 
>>Stephen Hemminger wrote:
>>
>>
>>>On Mon, 21 Aug 2006 16:21:07 +0200
>>>Jon Wikne <wikne@cheetah.uio.no> wrote:
>>>
>>>
>>>>Daniel Drake wrote:
>>>>
>>>>
>>>>>Jon Wikne wrote:
>>>>>
>>>>>
>>>>>>What happens is typically this: After transeferring some
>>>>>>data, ranging from less than 100kB to 10MB, the upload freezes,
>>>>>>i.e. gets no further. Use of ping shows the connection is
>>>>>>effectively dead. If I do a sequence /sbin/ifdown eth0
>>>>>>/sbin/ifup eth0 the upload might resume, but stops again
>>>>>>shortly. The phenomenon seems to occur sooner if the path
>>>>>>to the remote system is _fast_ (low ping times).
>>>>>
>>>>>You can try applying this patch:
>>>>>http://developer.osdl.org/shemminger/prototypes/sky2-proc-debug.patch
>>>>>
>>>>>It will add a /proc/net/sky2/ethX file, which lists the status of the TX 
>>>>>and status rings. You should compare the contents of this file during 
>>>>>normal operation to when the interface has hung.
>>>>
>>>>Thanks, Daniel. I applied the patch.
>>>>
>>>>The output of 'cat /proc/net/sky2/eth0' under normal circumstances
>>>>is here:
>>>>
>>>>http://puma.uio.no/sky2/sky2-status-normal.txt
>>>>
>>>>After the interface hangs, 'cat /proc/net/sky2/eth0' causes the
>>>>whole computer to hang completely. No kernel oops or other
>>>>messages in the console window. Power down is the only
>>>>solution.... :-[ No log entries after reboot.
>>>>
>>>
>>>It could be the code in the debug patch is walking off into space.
>>>The smaller version of the same patch, doesn't walk but just reports
>>>the index values.
>>
>>[ patch ]
>>
>>OK, I applied that. Part of it (5 hunks) had to be done manually, since
>>it appeared not to be relative to the version in 2.6.18-rc4 which I was
>>using.
>>
>>The result is:
>>
>>Normal operation:
>>Status ring (empty)
>>Tx ring (empty)
>>Rx pending hw get=60 put=256 last=511
> 
> 
> The chip has prefetched some of the 254 frames we gave it.
> 
> 
>>Error condition:
>>Status ring (empty)
>>Tx ring 338..378
> 
> 
> 40 packets waiting to send
> 
> 
>>Rx pending hw get=316 put=0 last=511
> 
> 
> So there are some frames waiting to be received as well.
> Looks like a missed interrupt.  Is there anything surprising in the
> ethtool stats?  (ethtool -S eth0)

Nothing that surprises me, anyway. The following log contains two
subsequent ethtool outputs: The first before the upload was started,
the second after the freeze occurred:

http://puma.uio.no/sky2/sky2-ethtool.txt

> In the past, when there were flow control hardware bugs
> there would be suspicious statistics like "1 mac pause frame received".

The only entries that refer to mac_pause are 0 both before and after
the freeze.

The system in question is a laptop, Toshiba Tecra A3, PTA30E-03502XNE
with serial number Z5310230K. I find no codes that are obvious to
state a date of manufacture, but it was bought in May 2006.


-- Jon
