From: Sasha Levin <sasha.levin@oracle.com>
Subject: Re: net: pptp: bad RCU usage and use after free
Date: Sun, 06 Apr 2014 10:01:57 -0400
Message-ID: <53415E55.4080307@oracle.com>
References: <534026C9.5010201@oracle.com> <1868621396767667@web26m.yandex.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=KOI8-R
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Dave Jones <davej@redhat.com>
To: "Oleg A. Arkhangelsky" <sysoleg@yandex.ru>,
	"xeb@mail.ru" <xeb@mail.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:49356 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753352AbaDFOCN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Apr 2014 10:02:13 -0400
In-Reply-To: <1868621396767667@web26m.yandex.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/06/2014 03:01 AM, Oleg A. Arkhangelsky wrote:
> 
> 
> 05.04.2014, 19:53, "Sasha Levin" <sasha.levin@oracle.com>:
> 
>> My guess is that we're racing the synchronize_rcu() in del_chan() with
>> the RCU protected read in lookup_chan_dst():
>>
>> pptp_release()
>>         del_chan() lookup_chan_dst()
>>                 enter synchronize_rcu()
>>                                                         sock = rcu_dereference(...)
>>                 exit synchronize_rcu()
>>         release_sock()
>>         sock_put()
>>                                                         opt = &sock->proto.pptp;
>>                                                         [ boom ]
> 
> Hmm...
> 
> IMHO, sock from callid_sock array must be NULL (not uninitialized) at
> that point, because del_chan() do:
> 
> RCU_INIT_POINTER(callid_sock[sock->proto.pptp.src_addr.call_id], NULL);
> 
> before rcu_synchronize(). I think that prevents access to freeing item
> in subsequent readers that go inside critical section when
> rcu_synchronize() is active.

Right, make sense. I'm completely lost then.


Thanks,
Sasha
