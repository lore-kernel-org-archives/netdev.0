From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: Re: [PATCH v6 net-next 2/5] net: implement support
 for low latency socket polling
Date: Thu, 30 May 2013 08:58:33 +0300
Message-ID: <51A6EA89.2070802@linux.intel.com>
References: <20130529063916.27486.3841.stgit@ladj378.jer.intel.com>
	<20130529063935.27486.18610.stgit@ladj378.jer.intel.com>
	<CAJZOPZJqF1FTLH3a3ZKUTA4ViesAZEkRi=dgd-ux8eRu9TyhBw@mail.gmail.com>
	<51A617D7.6000406@linux.intel.com>
	<CAJZOPZLC=drE9dTpnj2hLdDmfnL+T4gOU1j1xYwbmYy-J9HaAQ@mail.gmail.com>
	<1369854520.5109.79.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Willem de Bruijn <willemb@google.com>, Or Gerlitz <or.gerlitz@gmail.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	HPA <hpa@zytor.com>, Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Alex Rosenbaum <alexr@mellanox.com>, linux-kernel@vger.kernel.org,
	Eliezer Tamir <eliezer@tamir.org.il>, Andi Kleen <andi@firstfloor.org>,
	Eilon Greenstien <eilong@broadcom.com>, David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1369854520.5109.79.camel@edumazet-glaptop>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 29/05/2013 22:08, Eric Dumazet wrote:
> On Wed, 2013-05-29 at 21:52 +0300, Or Gerlitz wrote:
>> Eliezer Tamir <eliezer.tamir@linux.intel.com> wrote:
>>> Or Gerlitz wrote:
>>
>>>> Unlike with TCP sockets, UDP sockets may receive packets from multiple
>>>> sources and hence the receiving context may be steered to be executed
>>>> on different cores through RSS or other Flow-Steering HW mechanisms
>>>> which could mean different napi contexts for the same socket, is that
>>>> a problem here? what's the severity?
>>
>>> Nothing will break if you poll on the wrong queue.
>>> Your data will come through normal NAPI processing of the right queue.
>>
>> Can you elaborate a little further, why you call this "wrong" and "right"?
>> --
>
> This definitely need some documentation, because before llpoll, device
> RX path was serviced by the cpu receiving the harwdare interrupt.
>
> So the "wrong" queue could add false sharing, and wrong NUMA
> allocations.

Yes,
To work properly when you have more than one NUMA node, you have to have 
packet steering set up, either by your NIC or by HW accelerated RFS.

I would like to add a short writeup of the design and suggested 
configuration. Where should it go?

------------------------------------------------------------------------------
Introducing AppDynamics Lite, a free troubleshooting tool for Java/.NET
Get 100% visibility into your production application - at no cost.
Code-level diagnostics for performance bottlenecks with <2% overhead
Download for free and get started troubleshooting in minutes.
http://p.sf.net/sfu/appdyn_d2d_ap1
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
