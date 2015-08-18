From: Noam Camus <noamc@ezchip.com>
Subject: RE: [v1 0/6] *** nps_enet fixups ***
Date: Tue, 18 Aug 2015 05:04:20 +0000
Message-ID: <DB4PR02MB2725A45B664C42E3AB7B98ED6780@DB4PR02MB272.eurprd02.prod.outlook.com>
References: <1439791119-26892-1-git-send-email-noamc@ezchip.com>
 <20150817.103607.1737876155019074073.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Alexey.Brodkin@synopsys.com" <Alexey.Brodkin@synopsys.com>,
	"vgupta@synopsys.com" <vgupta@synopsys.com>,
	Tal Zilcer <talz@ezchip.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150817.103607.1737876155019074073.davem@davemloft.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Miller [mailto:davem@davemloft.net] 
Sent: Monday, August 17, 2015 8:36 PM


> You should not move TX completion out of NAPI handling, NAPI poll is exactly where it belongs.
>
> If you handle it in hardware interrupt context you have to use
> dev_kfree_skb_irq() which defers the operation to software interrupt context anyways and is thus expensive.

> Whereas if you keep TX completion in your NAPI handler the kfree is handled synchronously and efficiently, as well as making SKB's potentially available for RX reclaim.

I followed "Hardware Architecture" section from:
http://www.linuxfoundation.org/collaborate/workgroups/networking/napi
and came up with "reduce processing latency" idea.

Anyway, I will restore TX completion back to NAPI poll.

> I'm not applying this series, you are doing with TX handling exactly what we tell people not to do.

I will come up with revised series in v2.

Noam
