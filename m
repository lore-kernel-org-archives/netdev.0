From: <raghavendra.koushik@wipro.com>
Subject: RE: Submission #3  for S2io 10GbE driver
Date: Tue, 2 Mar 2004 19:16:22 +0530
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4223A04BF7D1B941A25246ADD0462FF50115AFCF@blr-m3-msg.wipro.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Cc: <leonid.grossman@s2io.com>, <netdev@oss.sgi.com>, <shemminger@osdl.org>,
        <hch@infradead.org>, <ravinandan.arakali@s2io.com>,
        <raghavendra.koushik@s2io.com>
Return-path: <netdev-bounce@oss.sgi.com>
content-class: urn:content-classes:message
To: <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Jeff,
	
	Really sorry about that "confidentiality notice" that gets attached. 
I have asked my sysAdmin to get rid of it. He has promised to do so ASAP. 
Hope this mail does not have it attached at the end :-). If at all the 
message still persists please ignore it as inconsequential to our discussion.

I Have a few more questions.

>>4) just delete the SET_NETDEV_DEV(), FREE_NETDEV, and IRQ_NONE 
>>compatibility defines.  these are in 2.4 just like 2.6.

Not all 2.4 kernels have them yet right? but since this driver is going
into 2.6 kernel if you want all these backward compatibility macros eliminated
I can do that.


>>13) in s2io_xmit, kfree the skb (drop it) if you don't have enough free 
>>space to queue it.  this is normally a BUG condition, since proper use 
>>of netif_{start,stop,wake}_queue() will guarantee that s2io_xmit will 
>>only be called when there is free space to queue another skb.

On returning error (non zero) from s2io_xmit, I think the calling function frees
the skb.
How s2io_xmit works is when I get a packet for Tx and I find that all the
Tx descriptors are owned by the NIC, I stop the queue and return error.
So I wouldn't know before hand whether free queue space is available or not.


Regards
Koushik


-----Original Message-----
From: Jeff Garzik [mailto:jgarzik@pobox.com] 
Sent: Monday, March 01, 2004 12:24 PM
To: Raghavendra Koushik (WT01 - EMBEDDED & PRODUCT ENGINEERING SOLUTIONS)
Cc: leonid.grossman@s2io.com; netdev@oss.sgi.com; shemminger@osdl.org; hch@infradead.org; ravinandan.arakali@s2io.com; raghavendra.koushik@s2io.com
Subject: Re: Submission #3 for S2io 10GbE driver


raghavendra.koushik@wipro.com wrote:
> Jeff,
>  Regarding Point # 37
> 
> 
>>>37) kill all of this:
>>>
>>>+/*  OS related system calls */
>>>+
>>>+#ifndef readq
>>>+static inline u64 read64(void *addr)
>>>+{
>>>+       u64 ret = 0;
>>>+       ret = readl(addr + 4);
>>>+       (u64) ret <<= 32;
>>>+       (u64) ret |= readl(addr);
> 
> 	[....]
> 
> I agree that read/write(32,16,8) are not used so can be eliminated, 
> but the read/write64 macros are essential because not all platforms 
> have defined the readq and writeq system calls. i386 for example 
> doesn't have readq/writeq and to write into the 64 bit registers of 
> the NIC, I use 2 successive 32 bits (readl/writel) operation to 
> achieve the 64 bit equivalent. This procedure does work on all the 
> platforms that we have tested on.

The code should use the kernel API -- readq/writeq -- not define its own 
API.  With regards to the missing readq/writeq on some architectures...

Short term, if some arches do not provide readq/writeq, provide your own 
definition (i.e. rename your write64 to a conditionally-defined writeq).

Long term, all Linux platforms need to provide readq/writeq, so we need 
to modify the architectures with the missing pieces.


> Confidentiality Notice
> 
> The information contained in this electronic message and any 
> attachments to this message are intended for the exclusive use of the 
> addressee(s) and may contain confidential or privileged information. 
> If you are not the intended recipient, please notify the sender at 
> Wipro or Mailadmin@wipro.com immediately and destroy all copies of 
> this message and any attachments.

Oh really?  ;-)  You should talk to your lawyers and sysadmins about 
sending email to open source people and lists...

Regards,

	Jeff
