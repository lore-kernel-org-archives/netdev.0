From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: Network Driver and NFS Root
Date: Tue, 19 Oct 2004 11:56:46 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4175636E.4050102@osdl.org>
References: <417040C2.6070408@rtcworks.com> <41754656.2060202@rtcworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Bob Wirka <bobwirka@rtcworks.com>
In-Reply-To: <41754656.2060202@rtcworks.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Bob Wirka wrote:

> First, thanks for the responses to my earlier post. I appreciate it.
>
> The ethernet driver code is now executing at boot time; adding either 
> '__initcall(init_fcn)' or 'init_module(init_fcn)' will cause the 
> kernel to call 'init_fcn'. That's the good news.
>
> The bad news is that the initializatin code causes a kernel oops when 
> accessing the 'net_device' structure that is passed to it by the 
> kernel (as a pointer). When the code either reads or writes to the 
> 'net_device' structure you get:
>
> Unable to handle kernel paging request at virtual address 00010f24
>
> Can anyone shed some light on this? I've printed out the value of the 
> 'net_device' pointer, and it's not a null pointer.
>
> Thanks,
>
> Bob Wirka
> Realtime Control Works
>
> ---------------ORIGINAL POST----------------------------
>
> Bob Wirka wrote:
>
>> Hello,
>>
>> I'm trying to build a kernel that mounts a NFS root file system. This 
>> is an embedded system; it uses an SMSC LAN91C111 network chip that is 
>> hardwired to I/O addres 0x300 and IRQ 5. I've been using the driver 
>> (as supplied by SMSC) as a module, and it works fine. Now I'm trying 
>> to incorporate it into the kernel build so that I can mount an NFS 
>> file system when the system boots.
>>
>> I've added the source code to the kernel tree, and modified the 
>> Makefile(s) and Config.in files so that the driver <<appears>> to be 
>> compiled into the kernel. The kernel will load, but the chip is not 
>> initialized and the NFS fails.
>>
>> Since I don't know how to pass the io address and irq number to the 
>> kernel, I've hard-coded them into the driver's init function (which I 
>> don't see being called).
>>
>> If someone could point me in the right direction, I'd appreciate it.
>
You should just configure the SMSC driver to be built in.  The 
module_init_call will be called correctly
on boot after the network core has been initialized.  If you use an 
initcall it will be too early, before
networking is ready.  You could use a deviceinitcall that would happen 
at the right time.
