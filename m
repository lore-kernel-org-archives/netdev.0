From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH v3 net-next 0/4] net: low latency Ethernet
	device polling
Date: Tue, 21 May 2013 10:30:53 -0400
Message-ID: <CA+FuTScYMPUsf0+67FAU0LBfuxhGT8JKyvL1WX=Rjomno75q2A@mail.gmail.com>
References: <20130520101552.14133.45953.stgit@ladj378.jer.intel.com>
	<519B632F.7040202@mellanox.com> <519B68A4.3010406@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <andi@firstfloor.org>,
	e1000-devel <e1000-devel@lists.sourceforge.net>,
	netdev@vger.kernel.org, HPA <hpa@zytor.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Alex Rosenbaum <alexr@mellanox.com>, Eliezer Tamir <eliezer@tamir.org.il>,
	Dave Miller <davem@davemloft.net>
To: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <519B68A4.3010406@linux.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

>> 2. How is the logic aware of RSS and RFS?
>>
>> With TCP sockets, the driver knows the specific ring it need to poll so
>> this should be mapped and provide the best latency.
>
>
> This code is blissfully oblivious of RFS and RSS, it only assumes that the
> packets for a socket are likely to continue to come on the same queue.
> The code is designed to be correct even if you get your data on the wrong
> queue. (your performance will suffer but no more than that.)
>

For low latency, you don't want to have to wait for the IPI that RPS
sets to redirect packets to another CPU.  However, this feature works
extremely well with hardware flow steering (nfc/ntuple) and
accelerated RFS, where the device will enqueue directly on an rxqueue
owned exclusively by the destination cpu (if configured correctly).

------------------------------------------------------------------------------
Try New Relic Now & We'll Send You this Cool Shirt
New Relic is the only SaaS-based application performance monitoring service 
that delivers powerful full stack analytics. Optimize and monitor your
browser, app, & servers with just a few lines of code. Try New Relic
and get this awesome Nerd Life shirt! http://p.sf.net/sfu/newrelic_d2d_may
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
