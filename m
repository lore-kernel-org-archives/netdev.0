From: John Heffner <jheffner@psc.edu>
Subject: Re: TCP connection stops after high load.
Date: Sun, 15 Apr 2007 11:31:45 -0400
Message-ID: <46224561.9010801@psc.edu>
References: <7e63f56c0704121411w6faea114g756d780b5a011463@mail.gmail.com>	 <20070412.141550.133265618.davem@davemloft.net> <7e63f56c0704150514q3b1271e8lcc9e8f30387d7540@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	greearb@candelatech.com
To: Robert Iakobashvili <coroberti@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer1.psc.edu ([128.182.58.100]:62440 "EHLO mailer1.psc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752844AbXDOPbz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 15 Apr 2007 11:31:55 -0400
In-Reply-To: <7e63f56c0704150514q3b1271e8lcc9e8f30387d7540@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Robert Iakobashvili wrote:
> Vanilla 2.6.18.3 works for me perfectly, whereas 2.6.19.5 and
> 2.6.20.6 do not.
> 
> Looking into the tcp /proc entries of 2.6.18.3 versus 2.6.19.5
> tcp_rmem and tcp_wmem are the same, whereas tcp_mem are
> much different:
> 
> kernel                  tcp_mem
> ---------------------------------------
> 2.6.18.3    12288 16384 24576
> 2.6.19.5      3072    4096   6144
> 
> 
> Is not it done deliberately by the below patch:
> 
> commit 9e950efa20dc8037c27509666cba6999da9368e8
> Author: John Heffner <jheffner@psc.edu>
> Date:   Mon Nov 6 23:10:51 2006 -0800
> 
>    [TCP]: Don't use highmem in tcp hash size calculation.
> 
>    This patch removes consideration of high memory when determining TCP
>    hash table sizes.  Taking into account high memory results in tcp_mem
>    values that are too large.
> 
> Is it a feature?
> 
> My machine has:
> MemTotal:       484368 kB
> and
> for all kernel configurations are actually the same with
> CONFIG_HIGHMEM4G=y
> 
> Thanks,
> 

Another patch that went in right around that time:

commit 52bf376c63eebe72e862a1a6e713976b038c3f50
Author: John Heffner <jheffner@psc.edu>
Date:   Tue Nov 14 20:25:17 2006 -0800

     [TCP]: Fix up sysctl_tcp_mem initialization.

     Fix up tcp_mem initial settings to take into account the size of the
     hash entries (different on SMP and non-SMP systems).

     Signed-off-by: John Heffner <jheffner@psc.edu>
     Signed-off-by: David S. Miller <davem@davemloft.net>

(This has been changed again for 2.6.21.)

In the dmesg, there should be some messages like this:

IP route cache hash table entries: 32768 (order: 5, 131072 bytes)
TCP established hash table entries: 131072 (order: 8, 1048576 bytes)
TCP bind hash table entries: 65536 (order: 6, 262144 bytes)
TCP: Hash tables configured (established 131072 bind 65536)

What do yours say?

Thanks,
   -John
