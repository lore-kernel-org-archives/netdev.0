From: Jeff Garzik <jgarzik@mandrakesoft.com>
Subject: Re: [Bonding-devel] Re: Bonding driver unreliable under high CPUload
Date: Tue, 17 Sep 2002 16:23:52 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3D878F58.7060706@mandrakesoft.com>
References: <Pine.GSO.4.44.0209171311080.11147-100000@falcon.csc.calpoly.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@digeo.com>,
   "Cureington, Tony" <tony.cureington@hp.com>,
   Pascal Brisset <pascal.brisset-ml@wanadoo.fr>,
   bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Chad N. Tindel" <ctindel@falcon.csc.calpoly.edu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Chad N. Tindel wrote:
>>>Will netif_carrier_ok(slave_dev) always work?  Do all drivers support the
>>>__LINK_STATE_NOCARRIER flag?
>>
>>
>>No.  Read again the precise language I used :)
> 
> 
> Right, well thats what I thought.  But how can we do what Andrew wants?


You'll need execute those ioctls from process context -- or call 
dev->do_ioctl() yourself with proper locking.  The latter would 
certainly be faster but you must be _very_ careful to avoid deadlocks. 
The former would certainly be preferred anyway, because calling an ioctl 
to check link state means you are hitting the slave_dev's phy, which is 
a very expensive operation in and of itself.

Unfortunately I am thinking that locking in bonding.c may need a 
re-think if you want to do this sort of stuff :(  Semaphores instead of 
a spinlocks may be appropriate, depending on the contexts in which 
link_state _really_ needs to be checked.

	Jeff
