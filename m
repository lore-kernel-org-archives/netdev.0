From: Fugang Duan <fugang.duan@nxp.com>
Subject: RE: [PATCH net-next V3 05/16] net: fec: reduce interrupts
Date: Wed, 6 Apr 2016 10:06:25 +0000
Message-ID: <VI1PR0401MB1855EF7033B5E1FA147A6C2FFF9F0@VI1PR0401MB1855.eurprd04.prod.outlook.com>
References: <1459909562-22865-1-git-send-email-troy.kisky@boundarydevices.com>
 <1459909562-22865-6-git-send-email-troy.kisky@boundarydevices.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "andrew@lunn.ch" <andrew@lunn.ch>,
 "stillcompiling@gmail.com" <stillcompiling@gmail.com>,
 "arnd@arndb.de" <arnd@arndb.de>,
 "sergei.shtylyov@cogentembedded.com" <sergei.shtylyov@cogentembedded.com>,
 "gerg@uclinux.org" <gerg@uclinux.org>, Fabio Estevam <fabio.estevam@nxp.com>,
 "johannes@sipsolutions.net" <johannes@sipsolutions.net>,
 "l.stach@pengutronix.de" <l.stach@pengutronix.de>,
 "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>,
 "tremyfr@gmail.com" <tremyfr@gmail.com>
To: Troy Kisky <troy.kisky@boundarydevices.com>, "netdev@vger.kernel.org"
 <netdev@vger.kernel.org>, "davem@davemloft.net" <davem@davemloft.net>,
 "lznuaa@gmail.com" <lznuaa@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1459909562-22865-6-git-send-email-troy.kisky@boundarydevices.com>
Content-Language: en-US
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

From: Troy Kisky <troy.kisky@boundarydevices.com> Sent: Wednesday, April 06, 2016 10:26 AM
> To: netdev@vger.kernel.org; davem@davemloft.net; Fugang Duan
> <fugang.duan@nxp.com>; lznuaa@gmail.com
> Cc: Fabio Estevam <fabio.estevam@nxp.com>; l.stach@pengutronix.de;
> andrew@lunn.ch; tremyfr@gmail.com; gerg@uclinux.org; linux-arm-
> kernel@lists.infradead.org; johannes@sipsolutions.net;
> stillcompiling@gmail.com; sergei.shtylyov@cogentembedded.com;
> arnd@arndb.de; Troy Kisky <troy.kisky@boundarydevices.com>
> Subject: [PATCH net-next V3 05/16] net: fec: reduce interrupts
> 
> By clearing the NAPI interrupts in the NAPI routine and not in the interrupt
> handler, we can reduce the number of interrupts. We also don't need any status
> variables as the registers are still valid.
> 
> Also, notice that if budget pkts are received, the next call to fec_enet_rx_napi
> will now continue to receive the previously pending packets.
> 
> To test that this actually reduces interrupts, try this command before/after patch
> 
> cat /proc/interrupts |grep ether; \
> ping -s2800 192.168.0.201 -f -c1000 ; \
> cat /proc/interrupts |grep ether
> 
> For me, before this patch is 2996 interrupts.
> After patch is 2010 interrupts.
> 
> Signed-off-by: Troy Kisky <troy.kisky@boundarydevices.com>
>

As my previous comments on V2, if you want to improve performance, you can try to separate tx and rx napi process like calling netif_tx_napi_add() to initialize tx NAPI context.
