From: David Greaves <david@dgreaves.com>
Subject: Re: 2.6.6 e1000 ifconfig: page allocation failure
Date: Fri, 18 Jun 2004 17:59:37 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40D31F79.3000903@dgreaves.com>
References: <468F3FDA28AA87429AD807992E22D07E01767AF6@orsmsx408>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jens Laas <jens.laas@data.slu.se>, Stephen Hemminger <shemminger@osdl.org>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Venkatesan, Ganesh" <ganesh.venkatesan@intel.com>
In-Reply-To: <468F3FDA28AA87429AD807992E22D07E01767AF6@orsmsx408>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On the 2.6.6 server machine:
  ifconfig eth0 mtu 9000
gives an oops in the usb?

Unable to handle kernel paging request at virtual address 92a8292a
 printing eip:
d1163305
*pde = 00000000
Oops: 0000 [#1]
CPU:    0
EIP:    0060:[<d1163305>]    Not tainted
EFLAGS: 00010286   (2.6.6)
EIP is at usb_buffer_free+0x15/0x50 [usbcore]
eax: cea2ec00   ebx: c13665e8   ecx: 00000001   edx: 92a8290a
esi: c13665ec   edi: cf0439dc   ebp: cf58eef4   esp: c3535f44
ds: 007b   es: 007b   ss: 0068
Process usb (pid: 2744, threadinfo=c3534000 task=cf245370)
Stack: cba80d00 c13665e8 c13665ec cf0439dc d106e3a6 cea2ec00 00002000 
cf636000
       0f636000 c13665e8 d106e4a9 c13665e8 cf122980 cffe0280 c01470d3 
cf0439dc
       cf122980 cf122980 00000000 cf27f200 c3534000 c0145a19 cf122980 
cf27f200
Call Trace:
 [<d106e3a6>] usblp_cleanup+0x46/0xb0 [usblp]
 [<d106e4a9>] usblp_release+0x59/0x60 [usblp]
 [<c01470d3>] __fput+0xe3/0x100
 [<c0145a19>] filp_close+0x59/0x90
 [<c0145aa0>] sys_close+0x50/0x60
 [<c0103f0b>] syscall_call+0x7/0xb

Code: 8b 4a 20 85 c9 74 07 8b 41 18 85 c0 75 04 83 c4 10 c3 8b 44
 <6>usb 1-1: new full speed USB device using address 3
drivers/usb/class/usblp.c: usblp0: USB Bidirectional printer dev 3 if 0 
alt 0 proto 2 vid 0x04B8 pid 0x0005
ifconfig: page allocation failure. order:3, mode:0x20
Call Trace:
 [<c013136f>] __alloc_pages+0x2af/0x2f0
 [<c01313d5>] __get_free_pages+0x25/0x40
 [<c01342e7>] cache_grow+0x87/0x230
 [<c01345c9>] cache_alloc_refill+0x139/0x200
 [<c0134960>] __kmalloc+0x70/0x80
 [<c02c1869>] alloc_skb+0x49/0xe0
 [<d110f262>] e1000_alloc_rx_buffers+0x62/0x100 [e1000]
 [<d110c045>] e1000_up+0x45/0xb0 [e1000]
 [<d110e4fc>] e1000_change_mtu+0x7c/0xd0 [e1000]
 [<c02c6e49>] dev_set_mtu+0x79/0x90
 [<c02c7429>] dev_ioctl+0x1e9/0x270
 [<c030032e>] inet_ioctl+0x8e/0xa0
 [<c02be895>] sock_ioctl+0xb5/0x250
 [<c015655d>] sys_ioctl+0xad/0x210
 [<c01129d0>] do_page_fault+0x0/0x4ff
 [<c0103f0b>] syscall_call+0x7/0xb

MemTotal:       256440 kB
MemFree:          2576 kB
Buffers:         18276 kB
Cached:         202048 kB
SwapCached:          0 kB
Active:         112492 kB
Inactive:       115324 kB
HighTotal:           0 kB
HighFree:            0 kB
LowTotal:       256440 kB
LowFree:          2576 kB
SwapTotal:      522100 kB
SwapFree:       522100 kB
Dirty:               8 kB
Writeback:           0 kB
Mapped:          14856 kB
Slab:            16920 kB
Committed_AS:    20272 kB
PageTables:        368 kB
VmallocTotal:   770040 kB
VmallocUsed:     10656 kB
VmallocChunk:   759264 kB



I have had similar on the stable box when it's been used for a while.
I did:
ifconfig eth1 mtu 9000
on the good machine and it gave me this:

Jun 18 16:33:08 haze kernel: printk: 1 messages suppressed.
Jun 18 16:33:08 haze kernel: ifconfig: page allocation failure. order:3, 
mode:0x20
Jun 18 16:33:08 haze kernel:  [__alloc_pages+728/848] 
__alloc_pages+0x2d8/0x350
Jun 18 16:33:08 haze kernel:  [__get_free_pages+37/64] 
__get_free_pages+0x25/0x40
Jun 18 16:33:08 haze kernel:  [kmem_getpages+32/176] kmem_getpages+0x20/0xb0
Jun 18 16:33:08 haze kernel:  [cache_grow+166/512] cache_grow+0xa6/0x200
Jun 18 16:33:08 haze kernel:  [cache_alloc_refill+342/544] 
cache_alloc_refill+0x156/0x220
Jun 18 16:33:08 haze kernel:  [__kmalloc+116/128] __kmalloc+0x74/0x80
Jun 18 16:33:08 haze kernel:  [alloc_skb+71/224] alloc_skb+0x47/0xe0
Jun 18 16:33:08 haze kernel:  [pg0+945227150/1069572096] 
e1000_alloc_rx_buffers+0x5e/0x100 [e1000]
Jun 18 16:33:08 haze kernel:  [pg0+945213509/1069572096] 
e1000_up+0x45/0xb0 [e1000]
Jun 18 16:33:08 haze kernel:  [pg0+945223248/1069572096] 
e1000_change_mtu+0x80/0x110 [e1000]
Jun 18 16:33:08 haze kernel:  [dev_set_mtu+121/144] dev_set_mtu+0x79/0x90
Jun 18 16:33:08 haze kernel:  [dev_ioctl+501/640] dev_ioctl+0x1f5/0x280
Jun 18 16:33:08 haze kernel:  [inet_ioctl+142/160] inet_ioctl+0x8e/0xa0
Jun 18 16:33:08 haze kernel:  [sock_ioctl+233/656] sock_ioctl+0xe9/0x290
Jun 18 16:33:08 haze kernel:  [sys_ioctl+239/608] sys_ioctl+0xef/0x260
Jun 18 16:33:08 haze kernel:  [do_page_fault+0/1242] do_page_fault+0x0/0x4da
Jun 18 16:33:08 haze kernel:  [syscall_call+7/11] syscall_call+0x7/0xb

it had
root@haze:~ # cat /proc/meminfo
MemTotal:      1036868 kB
MemFree:          7564 kB
Buffers:         30720 kB
Cached:         756496 kB
SwapCached:          0 kB
Active:         553348 kB
Inactive:       362700 kB
HighTotal:      131056 kB
HighFree:          252 kB
LowTotal:       905812 kB
LowFree:          7312 kB
SwapTotal:           0 kB
SwapFree:            0 kB
Dirty:               0 kB
Writeback:           0 kB
Mapped:         179532 kB
Slab:           105264 kB
Committed_AS:   298092 kB
PageTables:       1504 kB
VmallocTotal:   114680 kB
VmallocUsed:      2112 kB
VmallocChunk:   112376 kB

I could repeat this by mtu 1500, mtu 9000.
Somehow the distro hadn't mkswap'ed the swap so I added swap and the 
problem went away.
if I swapoff then every time I set the mtu to 9000 I get the page 
allocation failure.

I don't think this should happen but I'm not sure if I *must* have swap?
Also I did this whilst the interface was up (it let me).

David


Venkatesan, Ganesh wrote:

>Jens/David:
>
>Did not mean to get off the list. For some reason, my subscription to
>netdev is not working (even after re-subscribing). So, I grabbed your
>message off of the archive.
>
>I am trying to recreate your failure scenario in our lab. In the
>meantime, please send me any new information you have on this issue.
>
>Thanks,
>ganesh 
> 
>-------------------------------------------------
>Ganesh Venkatesan
>Network/Storage Division, Hillsboro, OR
>
>-----Original Message-----
>From: David Greaves [mailto:david@dgreaves.com] 
>Sent: Friday, June 18, 2004 5:52 AM
>To: Jens Laas
>Cc: Stephen Hemminger; netdev@oss.sgi.com; Venkatesan, Ganesh
>Subject: Re: 2.6.6 e1000 NETDEV WATCHDOG: eth0: transmit timed out+
>delay scheduler
>
>New info:
>I booted into XP and the card works there - so it doesn't look like a 
>simple hardware incompatibility.
>[I've got no real way to test the performance but cygwin's wget against 
>apache1.3 on the linux box returns about 25M/s initially and then 15M/s 
>sustained for 500Mb]
>
>Jens Laas wrote:
>
>  
>
>>>I'm speaking with Ganesh Venkatesan at intel about it. Ganesh you 
>>>went off list - do you want to include Jens or maybe go back on-list?
>>>      
>>>
>>If others run into this problem I'm sure they'll appreciate if its on 
>>list.
>>Since we have no idea what causes this (AFAIK) it may be a more 
>>general problem than the device driver.
>>    
>>
>
>I tend to agree - but I wasn't sure if this was the place and I'll do as
>
>I'm told ;)
>
>  
>
>>>A simple failure case for me is : 'ping -s 1500 '
>>>This doesn't cause the timout but doesn't succeed either.
>>>
>>>ping -f with standard packet size succeeds (slow rate though) and 
>>>doesn't timeout.
>>>      
>>>
>>
>>I dont see the ping problems at all. Unless you try to ping when the 
>>interface has "hanged" ?
>>    
>>
>
><sigh> thought that might be helpful.
>Ping with -s and -f seems to allow me to trigger errors and it seems a 
>lot more debug-able than scp or nfs :)
>No all tests are when it's reset and 'clean'
>
>  
>
>>>============
>>>From hereon down it's 2.6.7 with Stephen's recent delay scheduler
>>>      
>>>
>patch
>  
>
>>>This changed the behaviour.
>>>      
>>>
>>
>>This is strange unless you are actually using the delay scheduler ?
>>Default is sch_generic (that is pfifo) that does not exhibit the 
>>problems correct by the patch.
>>    
>>
>
>I'll go back and double check in case I cocked up...
>(I noticed the e1000 module rebuild but you're right that's incidental)
>
>I've rebuilt the kernel and modules with and w/o patch and rebooted a 
>few times and I can't reproduce that effect - sorry for the red herring.
>So after I reverted Stephens patch the results I reported are still 
>reproducable w/o the patch.
>
>  
>
>>>10592 packets transmitted, 10591 packets received, 0% packet loss
>>>round-trip min/avg/max = 5.4/5.5/83.5 ms
>>>
>>>Increasing Transmit Descriptors to 4096 avoids the No buffer space 
>>>available with packet sizes up to -s65468 (still 100% failure though)
>>>      
>>>
>>Increasing nr of buffers is not a way to fix the problem.
>>    
>>
>
>agreed - however in my ignorance of the deep behaviour I'm reporting 
>things that affect behaviour in ways I don't expect.
>I expected it to take longer to run out of buffers - that didn't happen
>:)
>
>(Anyway, on retesting I find that this was wrong - I suspect the 
>interface was down and I didn't notice)
>
>  
>
>>I had hoped to hear something about this from Scott..
>>    
>>
>
>I'm happy to hear from anyone - I don't have *that* long until my RMA 
>option expires and I don't fancy keeping them as ornaments!
>
>David
>
>
>
>
>  
>
