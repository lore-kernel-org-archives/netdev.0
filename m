From: Krishna Kumar <krkumar@us.ibm.com>
Subject: Re: Question about netlink
Date: Tue, 08 Jul 2003 13:27:54 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F0B294A.9060302@us.ibm.com>
References: <3F0B10E3.9050700@us.ibm.com> <20030709.040433.89038276.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20030709.040433.89038276.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I am still not convinced how it works, though I have been trying to seek the truth for some
time now :-).

These routines 'get' the value of args[0] and then 'set' it to the resultant value. How is
this value set in the first place to the user provided value ? It seems to be initialized
to ZERO in netlink_dump_start(). The only way it seems to use the value is if it gets
called twice from netlink_dump(), the first time cb->args will be set to zero's while the
second time it will have the values set by the first invocation to the same routine. Am I
missing something or is 'args' not intended for user specified arguments ? If so, how
should we access the arguments passed by the user ?

Thanks,

- KK

YOSHIFUJI Hideaki wrote:
> In article <3F0B10E3.9050700@us.ibm.com> (at Tue, 08 Jul 2003 11:43:47 -0700), Krishna Kumar <krkumar@us.ibm.com> says:
> 
> 
>>Some of the netlink routines (eg rtnetlink_dump_ifinfo or inet6_dump_ifaddr) seem to get
>>user arguments from cb->args['n']. However I was not able to figure out where the
>>arguments are being set, can anyone help ?
> 
> 
> Take a look at net/core/rtnelink.c:rtnetlink_dump_ifinfo()
>                net/core/neighbour.c:neigh_dump_{info,table}()
> and seek the truth. :-)
> 
> --yoshfuji
> 
