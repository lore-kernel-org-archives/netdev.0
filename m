From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH] bonding: fix bond 6 mode change MAC of arp reply from
 vif to cause Domu's network unreachable intermittently
Date: Tue, 30 Oct 2012 03:03:05 +0000 (UTC)
Message-ID: <k6ng19$fvd$1@ger.gmane.org>
References: <1351565271-5888-1-git-send-email-zheng.x.li@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 30 Oct 2012 at 02:47 GMT, Zheng Li <zheng.x.li@oracle.com> wrote:
> +			struct slave *tmp_slave = NULL;
> +			int i = 0, found_mac = 0;
> +			bond_for_each_slave(bond, tmp_slave, i) {
> +				if (ether_addr_equal_64bits(arp->mac_src,
> +						tmp_slave->dev->dev_addr)) {
> +					found_mac = 1;
> +					break;
> +				}
> +			}
> +			if (found_mac)
> +				memcpy(arp->mac_src, tx_slave->dev->dev_addr,
> +					ETH_ALEN);

A nitpick: found_mac can be a bool.
