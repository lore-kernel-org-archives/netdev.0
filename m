From: manu gautam <manugautam25@hotmail.com>
Subject: FW: System Hang while trying to send over TCP socket with very less
 free m/m
Date: Wed, 29 Jul 2009 13:54:27 +0530
Message-ID: <BLU141-W7E99313C2CA3BE069EC5DD4120@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752357AbZG2IY3@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi,

I am running 2.6.12 kernel with kernel PREEMPTION being OFF. 
While sending data over TCP socket I am experiencing system hang. What is happening actually is that the system is low in free memory and the sk_stream_alloc_pskb call in tcp_sendmsg fails and the control goes to "sk_stream_wait_memory" function. Inside this function we are calling schedule_timeout only if "sk_stream_memory_free(sk) && vm_wait" check is false. In my case what happens is that this check is always true and we don't do schedule_timeout which results in the system hang.
With preemption being OFF it becomes a kind of deadlock where the one thread is waiting for the memory to be freed but it is not getting scheduled out. 

I also checked on the latest kernel but there also I dont see any fix for this issue. 

Please excuse me if I have pasted it to some wrong mailing list.
Regards,Manu
_________________________________________________________________
Missed any of the IPL matches ? Catch a recap of all the action on MSN Videos
http://msnvideos.in/iplt20/msnvideoplayer.aspx