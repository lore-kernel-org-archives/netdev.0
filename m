From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2/9] PKT_SCHED: tc filter extension API
Date: Fri, 31 Dec 2004 10:52:54 +0100
Message-ID: <41D52176.80703@trash.net>
References: <20041230122652.GM32419@postel.suug.ch>	 <20041230123023.GO32419@postel.suug.ch>  <41D4A4D2.4000109@trash.net> <1104469362.1049.224.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, "David S. Miller" <davem@davemloft.net>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1104469362.1049.224.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:
> On Thu, 2004-12-30 at 20:01, Patrick McHardy wrote:
> 
>>This isn't right (its also wrong in the current code). If the
>>CPU reorders stores and another CPU looks at dst->action at
>>the wrong time it might see an inconsistent structure. 
> 
> 
> I think an xchg around the else should fix this.

Yes.

>>I also wonder if anyone
>>actually knows why we need the xchg (here and in all the other
>>places), it looks totally useless.
> 
> All these were put in by Alexey and the LinuxWay(tm) took effect.
> an xchg puts almost a lock and ensures an atomic swap. I dont see any
> harm in leaving it as is - just needs fixing the else

No real harm, but it still should be removed IMO, or used _instead_
of tcf_tree_lock in this place. I've asked myself multiple times what
it is meant for and I've seen others do the same, this alone justifies
removing it. Another reason is what you call LinuxWay(tm), strange
things spread on their own and at some time you have to touch lots of
files to get rid them. So its best to do it as early as possible.

Regards
Patrick
