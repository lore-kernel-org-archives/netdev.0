From: Arun Sharma <asharma@fb.com>
Subject: Re: route add default fails with ESRCH?
Date: Wed, 22 Feb 2012 15:03:11 -0800
Message-ID: <4F45742F.1070605@fb.com>
References: <4F3F0158.2020406@fb.com> <4F4541E5.5040700@fb.com> <alpine.LFD.2.00.1202222319150.1603@ja.ssi.bg> <4F45638B.30305@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4F45638B.30305@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2/22/12 1:52 PM, Arun Sharma wrote:

> I'll try to figure out why my RT_TABLE_MAIN was empty after my network
> startup scripts finished. But given my experience with 2.6.38, fib_hash
> handled this case just fine and fib_trie broke it :(
>

Turns out that we had a /sbin/ifup-local that deleted all the routes 
including default gw and populated the route afresh.

route del default gw ...
ip route | grep -v scope | awk '{print $1}' | while read route; do ip 
route flush $route; done

This worked fine with fib_hash, but breaks with fib_trie. I'll 
investigate why this was done and look for a workaround if possible.

  -Arun
