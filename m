From: Sergei Shtylyov <sshtylyov@ru.mvista.com>
Subject: Re: [PATCH] netpoll: trapping fix/cleanup
Date: Wed, 04 Apr 2007 17:03:54 +0400
Message-ID: <4613A23A.7080505@ru.mvista.com>
References: <200703302340.27343.sshtylyov@ru.mvista.com>
	<46130DD6.6050707@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mpm@selenic.com,
	shemminger@linux-foundation.org, mhuth@mvista.com,
	kgdb-bugreport@lists.sourceforge.net
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <kgdb-bugreport-bounces@lists.sourceforge.net>
In-Reply-To: <46130DD6.6050707@pobox.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/kgdb-bugreport>,
	<mailto:kgdb-bugreport-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=kgdb-bugreport>
List-Post: <mailto:kgdb-bugreport@lists.sourceforge.net>
List-Help: <mailto:kgdb-bugreport-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/kgdb-bugreport>,
	<mailto:kgdb-bugreport-request@lists.sourceforge.net?subject=subscribe>
Sender: kgdb-bugreport-bounces@lists.sourceforge.net
Errors-To: kgdb-bugreport-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Hello.

Jeff Garzik wrote:

>> CONFIG_NETPOLL_TRAP causes the TX queue controls to be completely 
>> bypassed in
>> the netpoll's "trapped" mode which easily causes overflows in the 
>> drivers with
>> short TX queues (most notably, in 8139too with its 4-deep queue).
>> Make this option more sensible by only bypassing TX softirq wakeup and 
>> remove
>> CONFIG_NETPOLL_RX option completely since there is *no* code depending 
>> on it.

>> Signed-off-by: Sergei Shtylyov <sshtylyov@ru.mvista.com>

> ACK but (a) DaveM not me should apply this,

    Oops, sorry. But he's only mentioned as IPv4/v6 maintainer. :-)

> and (b) I would check with 
> netpoll people to see what that define  is there for.

    Amit Kale and I were already asking about CONFIG_NETPOLL_TRAP here 1+ 
months ago and got no replies. Well I'll try to CC Matt Mackall...
    If you mean CONFIG_NETPOLL_RX, there was #ifdef's in the early version of 
netpoll support:

http://git.kernel.org/?p=linux/kernel/git/tglx/history.git;a=commitdiff;h=8fb9cf8ab6c0ccb1b17b32c05dc9da3cc96ac229

but later they were removed but the option left:	

http://git.kernel.org/?p=linux/kernel/git/tglx/history.git;a=commitdiff;h=e3c265bcf67f21d847e970e71504890f61f37824

>     Jeff

WBR, Sergei

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
