From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCHv3 3/3] net: velocity: Add platform device support to VIA
 velocity driver
Date: Tue, 30 Apr 2013 01:04:50 +0200
Message-ID: <20130429230450.GA2620@electric-eye.fr.zoreil.com>
References: <1367264772-4557-1-git-send-email-linux@prisktech.co.nz>
 <1367264772-4557-4-git-send-email-linux@prisktech.co.nz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: vt8500-wm8505-linux-kernel@googlegroups.com, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
 davem@davemloft.net
To: Tony Prisk <linux@prisktech.co.nz>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <1367264772-4557-4-git-send-email-linux@prisktech.co.nz>
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

Tony Prisk <linux@prisktech.co.nz> :
[...]
> +static int velocity_remove(void *pdev, enum velocity_bus_type bustype)
> +{
> +	struct net_device *netdev;
> +	struct velocity_info *vptr;
> +	int pci = (bustype == BUS_PCI) ? 1 : 0;
> +
> +	if (pci)
> +		netdev = pci_get_drvdata(pdev);
> +	else
> +		netdev = platform_get_drvdata(pdev);

The caller knows how to retrieve the net_device pointer, whence
the struct velocity_info pointer, whence any bustype dependent
function pointer to alleviate the "if (pci)" and CONFIG stuff.

If you are not convinced, please consider turning the void *
into an union *.

-- 
Ueimor
