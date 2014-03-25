From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 3/3] net: hisilicon: new hip04 ethernet driver
Date: Tue, 25 Mar 2014 10:21:42 -0700
Message-ID: <1395768102.12610.159.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1395670496-17381-1-git-send-email-zhangfei.gao@linaro.org>
 <17142825.cN9DfpvuLc@wuerfel>
 <CAGVrzcbNbc1fyq1cuox8SVZHq1ADNah3CfyXSR--4ZWkf2EtTw@mail.gmail.com>
 <21873900.AIOr1ryy37@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mark Rutland <mark.rutland@arm.com>,
 "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
 Florian Fainelli <f.fainelli@gmail.com>,
 Russell King - ARM Linux <linux@arm.linux.org.uk>,
 Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
 netdev <netdev@vger.kernel.org>, Zhangfei Gao <zhangfei.gao@gmail.com>,
 Zhangfei Gao <zhangfei.gao@linaro.org>,
 "David S. Miller" <davem@davemloft.net>,
 linux-arm-kernel <linux-arm-kernel@lists.infradead.org>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <21873900.AIOr1ryy37@wuerfel>
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

On Tue, 2014-03-25 at 18:05 +0100, Arnd Bergmann wrote:
> On Tuesday 25 March 2014 10:00:30 Florian Fainelli wrote:
> > 2014-03-25 1:12 GMT-07:00 Arnd Bergmann <arnd@arndb.de>:
> > > On Tuesday 25 March 2014 12:06:31 Zhangfei Gao wrote:
> > >> Dear Arnd
> > >>
> > >> On Mon, Mar 24, 2014 at 11:18 PM, Arnd Bergmann <arnd@arndb.de> wrote:
> > >> > On Monday 24 March 2014 22:14:56 Zhangfei Gao wrote:
> > >> >
...
> > >> > I think you still need to find a solution to ensure that the tx reclaim is
> > >> > called eventually through a method other than start_xmit.
> > >>
> > >> In the iperf stress test, if move reclaim to poll, there is some
> > >> error, sometimes sending zero packets.
> > >> While keep reclaim in the xmit to reclaim transmitted packets looks
> > >> stable in the test,
> > >> There TX_DESC_NUM desc can be used.
> > >
> > > What I meant is that you need a correct implementation, presumably
> > > you added a bug when you moved the function to poll(), and also you
> > > forgot to add a timer.
> > 
> > Using a timer to ensure completion of TX packets is a trick that
> > worked in the past, but now that the networking stack got smarter,
> > this might artificially increase the processing time of packets in the
> > transmit path, and this will defeat features like TCP small queues
> > etc.. as could be seen with the mvneta driver [1]. The best way really
> > is to rely on TX completion interrupts when those exist as they cannot
> > lie about the hardware status (in theory) and they should provide the
> > fastest way to complete TX packets.
> 
> By as Zhangfei Gao pointed out, this hardware does not have a working
> TX completion interrupt. Using timers to do this has always just been
> a workaround for broken hardware IMHO.

For this kind of drivers, calling skb_orphan() from ndo_start_xmit() is
mandatory.
