From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] fix numbering of lines in /proc/net/tcp
 (linux-2.6.0-test7)
Date: Wed, 15 Oct 2003 01:38:48 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031015.013848.133364889.yoshfuji@linux-ipv6.org>
References: <200310141619.h9EGJWWB013461@ginger.lcs.mit.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
        jmorris@redhat.com, netdev@oss.sgi.com, torvalds@osdl.org,
        linux-kernel@vger.kernel.org, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: shep@alum.mit.edu
In-Reply-To: <200310141619.h9EGJWWB013461@ginger.lcs.mit.edu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <200310141619.h9EGJWWB013461@ginger.lcs.mit.edu> (at Tue, 14 Oct 2003 12:19:32 -0400), Tim Shepard <shep@alum.mit.edu> says:

> However, on a linux-2.4.21 system with ipv6 listeners, the numbers are
> shared between ipv4 and ipv6:
> 
> $ cat /proc/net/tcp
>   sl  local_address rem_address   st tx_queue rx_queue tr tm->when retrnsmt   uid  timeout inode                                                     
>    0: 00000000:1F40 00000000:0000 0A 00000000:00000000 00:00000000 00000000     0        0 580 1 c702f820 300 0 0 2 -1                               
>    1: 00000000:16E9 00000000:0000 0A 00000000:00000000 00:00000000 00000000   101        0 297102 1 c718dba0 300 0 0 2 -1                            
>    2: 00000000:006F 00000000:0000 0A 00000000:00000000 00:00000000 00000000     0        0 145 1 c77e5420 300 0 0 2 -1                               
>    4: 00000000:1770 00000000:0000 0A 00000000:00000000 00:00000000 00000000     0        0 840 1 c6cf94c0 300 0 0 2 -1                               
:
> $ cat /proc/net/tcp6 
>   sl  local_address                         remote_address                        st tx_queue rx_queue tr tm->when retrnsmt   uid  timeout inode                                              
>    3: 00000000000000000000000000000000:0050 00000000000000000000000000000000:0000 0A 00000000:00000000 00:00000000 00000000     0        0 6630 1 c702fbc0 300 0 0 2 -1                       
> 
> 
> 
> I am not sure what the behavior is supposed to be.  Is there a spec
> anywhere for the interface with /proc/net/tcp?

Yes, I think the original is okay because the bucket is shared between
tcp6 and tcp4, and I don't want to change this behavior in 2.6 from 2.4.x.
(so, we need to fix 2.6.x.)

--yoshfuji
