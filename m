From: James Morris <jmorris@redhat.com>
Subject: Re: Oops in __xfrm4_state_lookup when setting up an IPSEC tunnel
 (fwd)
Date: Wed, 5 Nov 2003 18:19:05 -0500 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Xine.LNX.4.44.0311051818010.16006-100000@thoron.boston.redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Here is some better debug info, also, he was able to resolve the issue by 
fixing his policy (previously posted to lkml), so it looks like a bug to be 
investigated.

---------- Forwarded message ----------
Date: Wed, 05 Nov 2003 10:26:58 -0500
From: David T Hollis <dhollis@davehollis.com>
To: James Morris <jmorris@redhat.com>
Cc: David S. Miller <davem@redhat.com>
Subject: Re: Oops in __xfrm4_state_lookup when setting up an IPSEC tunnel

James Morris wrote:

>On Wed, 5 Nov 2003, David T Hollis wrote:
>
>
>  
>
>>>>EIP is at __xfrm4_state_lookup+0x6f/0xa0
>>>>   
>>>>
>>>>        
>>>>
>>>If you compile your kernel with -g, you should be able to find the 
>>>corresponding line of code (e.g. with addr2line).
>>> 
>>>
>>>      
>>>
Here's a much better dump of information.  This time I went with no 
netfilter stuff loaded, very bare bones.  Without those modules, the 
dump didn't scroll past the screen so I was able to get the rather 
important bit about KERNEL: ASSERTION (x->km.state == XFRM_STATE_DEAD) 
failed at net/xfrm/xfrm_state.c (193) (this is in 
__xfrm_state_destroy).  So the state of my transform is set to dead for 
some reason, next question is why that would be.  I still die in 
__xfrm4_state_lookup on the list_for_each_entry. 


KERNEL: ASSERTION (x->km.state == XFRM_STATE_DEAD) failed at 
net/xfrm/xfrm_state.c (193)
Unable to handle kernel paging request at virtual address 39302035
 printing eip:
c02a7c8f
*pde = 00000000
Oops: 0000 [#1]
CPU:  0
EIP:   0060:[<c02a7c8f>]     Not tainted
EFLAGS: 00010282
EIP is at __xfrm4_state_lookup+0x6f/0xa0


Call Trace:
xfrm_state_lookup+0x4c/0x70
xfrm4_rcv_encap+0x9f/0x390
default_wake_function+0x2a/0x30
xfrm4_rcv+0x17/0x20
ip_local_deliver+0xe5/0x230
ip_rcv+0x31f/0x470
netif_recieve_skb+0x183/0x200
