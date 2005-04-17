From: Patrick McHardy <kaber@trash.net>
Subject: Re: ACPI/HT or Packet Scheduler BUG?
Date: Sun, 17 Apr 2005 19:46:16 +0200
Message-ID: <4262A0E8.9020905@trash.net>
References: <Pine.LNX.4.61.0504081225510.27991@blackblue.iasi.rdsnet.ro> <Pine.LNX.4.61.0504121526550.4822@blackblue.iasi.rdsnet.ro> <Pine.LNX.4.61.0504141840420.13546@blackblue.iasi.rdsnet.ro> <1113601029.4294.80.camel@localhost.localdomain> <1113601446.17859.36.camel@localhost.localdomain> <1113602052.4294.89.camel@localhost.localdomain> <20050415225422.GF4114@postel.suug.ch> <20050416014906.GA3291@gondor.apana.org.au> <20050416110639.GI4114@postel.suug.ch> <20050416111236.GA31550@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, Steven Rostedt <rostedt@goodmis.org>,
        hadi@cyberus.ca, netdev <netdev@oss.sgi.com>,
        Tarhon-Onu Victor <mituc@iasi.rdsnet.ro>, kuznet@ms2.inr.ac.ru,
        devik@cdi.cz, linux-kernel@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050416111236.GA31550@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> On Sat, Apr 16, 2005 at 01:06:39PM +0200, Thomas Graf wrote:
> 
>>qdisc_destroy can still be invoked without qdisc_tree_lock via the
>>deletion of a class when it calls qdisc_destroy to destroy its
>>leaf qdisc.
>
> Indeed.  Fortuantely HTB seems to be safe as it calls sch_tree_lock
> which is another name for qdisc_tree_lock.  CBQ on the other hand
> needs to have a little tweak.

HTB also needs to be fixed. Destruction is usually defered by the
refcnt until ->put(), htb_put() doesn't lock the tree. Same for
HFSC and CBQ.

Regards
Patrick
