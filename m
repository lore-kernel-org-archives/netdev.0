From: Patrick McHardy <kaber@trash.net>
Subject: Re: 2.6.11 on AMD64 traps
Date: Wed, 09 Mar 2005 21:34:56 +0100
Message-ID: <422F5DF0.6060904@trash.net>
References: <200503081900.18686.vanco@satro.sk> <422DF07D.7010908@tomt.net> <422F525F.90404@trash.net> <200503092124.35190.vanco@satro.sk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Andre Tomt <andre@tomt.net>,
        linux-kernel@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Michal Vanco <vanco@satro.sk>
In-Reply-To: <200503092124.35190.vanco@satro.sk>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Michal Vanco wrote:
> On Wednesday 09 March 2005 20:45, Patrick McHardy wrote:
>>
>>This patch should fix it. The crash is caused by stale pointers,
>>the pointers in fib_iter_state are not reloaded after seq->stop()
>>followed by seq->start(pos > 0).
> 
> Well. Trap vanished after applying this patch, but another weird thing occurs:
> 
> # ip route show | wc -l
> 156033
> # date; time ip route show > /dev/null; date; time netstat -rn > /dev/null
> Wed Mar  9 22:15:21 CET 2005
> 
> real    0m0.656s
> user    0m0.415s
> sys     0m0.242s
> Wed Mar  9 22:15:22 CET 2005
> 
> real    6m41.472s
> user    0m1.261s
> sys     6m40.143s

Yes, I know it is totally inefficient. Just use ip route, which doesn't
suffer from this problem.

Regards
Patrick
