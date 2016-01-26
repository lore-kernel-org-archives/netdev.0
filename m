From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH/RFC v4 net-next] ravb: Add dma queue interrupt support
Date: Tue, 26 Jan 2016 09:23:01 +0900
Message-ID: <20160126002300.GA27856@verge.net.au>
References: <1453650775-19886-1-git-send-email-ykaneko0929@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Magnus Damm <magnus.damm@gmail.com>, linux-sh@vger.kernel.org
To: Yoshihiro Kaneko <ykaneko0929@gmail.com>
Return-path: <linux-sh-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1453650775-19886-1-git-send-email-ykaneko0929@gmail.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 25, 2016 at 12:52:55AM +0900, Yoshihiro Kaneko wrote:
> From: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
> 
> This patch supports the following interrupts.
> 
> - One interrupt for multiple (descriptor, error, management)
> - One interrupt for emac
> - Four interrupts for dma queue (best effort rx/tx, network control rx/tx)
> 
> This patch improve efficiency of the interrupt handler by adding the
> interrupt handler corresponding to each interrupt source described
> above. Additionally, it reduces the number of times of the access to
> EthernetAVB IF.
> 
> Signed-off-by: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
> Signed-off-by: Yoshihiro Kaneko <ykaneko0929@gmail.com>

I have tested this patch and the result seems positive.
Please let me know if any more/different testing would help.

My test was to examine /proc/interrupts after booting a Salvator-X board
using NFS root. The test used net-next merged with v4.5-rc1 (for
r8a7795/Salvator-X support). I then applied this patch.

Without this patch:
# grep eth /proc/interrupts
 74:      13002          0          0          0     GIC-0  93 Level     eth0
 76:          3          0          0          0     GIC-0  95 Level     eth0

With this patch:

# grep eth /proc/interrupts
 52:       8744          0          0          0     GIC-0  71 Level     eth0:ch0:rx_be
 53:          0          0          0          0     GIC-0  72 Level     eth0:ch1:rx_nc
 70:       4277          0          0          0     GIC-0  89 Level     eth0:ch18:tx_be
 71:          0          0          0          0     GIC-0  90 Level     eth0:ch19:tx_nc
 74:          0          0          0          0     GIC-0  93 Level     eth0:ch22:multi
 76:          3          0          0          0     GIC-0  95 Level     eth0:ch24:emac

Please feel free to add:

Tested-by: Simon Horman <horms+renesas@verge.net.au>
