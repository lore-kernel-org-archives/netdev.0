From: Neil Horman <nhorman@redhat.com>
Subject: Re: Network Driver and NFS Root
Date: Tue, 19 Oct 2004 14:31:57 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41755D9D.4080304@redhat.com>
References: <417040C2.6070408@rtcworks.com> <41754656.2060202@rtcworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: no To-header on input <unlisted-recipients:;>, linux-net@vger.kernel.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Bob Wirka <bobwirka@rtcworks.com>
In-Reply-To: <41754656.2060202@rtcworks.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Bob Wirka wrote:
> First, thanks for the responses to my earlier post. I appreciate it.
> 
> The ethernet driver code is now executing at boot time; adding either 
> '__initcall(init_fcn)' or 'init_module(init_fcn)' will cause the kernel 
> to call 'init_fcn'. That's the good news.
> 
> The bad news is that the initializatin code causes a kernel oops when 
> accessing the 'net_device' structure that is passed to it by the kernel 
> (as a pointer). When the code either reads or writes to the 'net_device' 
> structure you get:
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
	Take a look at any of the other working net drivers in the kernel.  You 
can pretty well cut-n-paste the net_device allocation/initalization code 
  from any of those drivers into yours.  Look for calls to 
alloc_etherdev to find places to start looking.

	Most likely you've forgotten to initalize some part of the structure 
before passing it to register_netdev, or perhaps you've passed  a 
pointer to a net_device structure that was allocated on the stack rather 
than from the heap.  Its not really possible to tell without looking 
through the code, but regardless, start comparing what you do in your 
initalization routine to what any of the other net drivers do in the 
same area of code, and your problem is likely to jump right out at you.

HTH
Neil

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
>>
>> Thank you,
>>
>> Bob Wirka
>> Realtime Control Works
>> -
>> To unsubscribe from this list: send the line "unsubscribe linux-net" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-net" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


-- 
/***************************************************
  *Neil Horman
  *Software Engineer
  *Red Hat, Inc.
  *nhorman@redhat.com
  *gpg keyid: 1024D / 0x92A74FA1
  *http://pgp.mit.edu
  ***************************************************/
