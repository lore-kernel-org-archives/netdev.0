From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 3/3] net: hisilicon: new hip04 ethernet driver
Date: Tue, 25 Mar 2014 18:57:21 +0100
Message-ID: <4392030.XayIa35sfH@wuerfel>
References: <1395670496-17381-1-git-send-email-zhangfei.gao@linaro.org>
 <21873900.AIOr1ryy37@wuerfel>
 <CAGVrzcZNM2gUHqq2m2jcaqs-AoWKo_DszYu5ozs2vTR6kFY0kA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mark Rutland <mark.rutland@arm.com>,
 "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
 Russell King - ARM Linux <linux@arm.linux.org.uk>,
 Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
 netdev <netdev@vger.kernel.org>, Zhangfei Gao <zhangfei.gao@gmail.com>,
 Zhangfei Gao <zhangfei.gao@linaro.org>,
 "David S. Miller" <davem@davemloft.net>,
 linux-arm-kernel <linux-arm-kernel@lists.infradead.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <CAGVrzcZNM2gUHqq2m2jcaqs-AoWKo_DszYu5ozs2vTR6kFY0kA@mail.gmail.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On Tuesday 25 March 2014 10:16:28 Florian Fainelli wrote:
> 
> Ok, well that's really unfortunate, to achieve the best of everything,
> the workaround should probably look like:
> 
> - keep reclaiming TX buffers in ndo_start_xmit() in case you push more
> packets to the NICs than your timer can free
> - reclaim TX buffers in NAPI poll() context for "symetrical" workloads
> where e.g: TCP ACKs received allow you to complete TX buffers
> - have a timer like you suggest which should help with transmit only
> workloads at a slow rate

Yes, that is what I was thinking, but with orphaning the tx skbs,
we can probably be a little smarter. Note that in order to check
the state of the queue, we have to do a read from uncached memory,
since the hardware also doesn't support cache coherent DMA.
We don't want to do that too often.

	Arnd
