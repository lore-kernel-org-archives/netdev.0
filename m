From: Boris Protopopov <borisp@mc.com>
Subject: Re: Linux SMP on 2.4.18-3
Date: Tue, 29 Oct 2002 20:40:17 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DBF3881.6070208@mc.com>
References: <Pine.GSO.4.30.0210280741020.9849-100000@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Cheng Jin <chengjin@cs.caltech.edu>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jamal, could you give some pointers as to how "NAPIfy" a 2.4.18-3/e1000-4.3.15 
setup ? Boris.

jamal wrote:
> 
> The IP network stack in linux is totaly reentrant. You could have a
> packet on _each_ processor in SMP concurently executing the same code. If
> you add anything, you need to take this into account.
> In non-NAPI based NICs such as yours, you could have reordering within
> the system (this is described in the NAPI paper). Either get it NAPIfied
> or get yourself a NAPI capable NIC such as tg3 based, e1000, Dlink gige
> etc.
> 
> cheers,
> jamal
> 
> On Sun, 27 Oct 2002, Cheng Jin wrote:
> 
> 
>>Hi,
>>
>>Please excuse me for asking questions on a rather old kernel.  We decided
>>to do kernel modificatios against 2.4.18-3 so we can't back it out now.
>>
>>On the SMP test machine we have at the lab (Dual 2.4 Ghz Xeons with one
>>SysKonnect Gigabit Ethernet card, SuperMicro P4DP6 MB), I observed TCP
>>functions being called simultaneously by both processors.  What I did was
>>to simply increment a counter (init to zero) and check whether it is one
>>in the functions under suspicion.  Sure enough, I see a lot of messages
>>printed out saying it is two.  Admittedly, my counter var is not protected
>>either, but seeing it becoming 2 is proof enough that the functions are
>>entered simultaneously (yes I decrement the counter before functions
>>return).
>>
>>I looked at the code fairly extensively, and I didn't see any lock for
>>these functions, tcp_send_skb, tcp_push_one, update_send_head, where
>>packets_out gets incremented.  The problem I was having was that
>>tp->packets_out got out of sync with the number of unacked packets on the
>>sk->write_queue.
>>
>>I would like to confirm with people that are involved with kernel
>>developement that what I observed was indeed correct.
>>
>>Thanks,
>>
>>Cheng
>>
>>Lab # 626 395 8820
>>
>>
> 
> 
> 
> 
> 
