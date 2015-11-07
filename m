From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net/qlcnic: fix mac address restore in bond mode
 5/6
Date: Sat, 07 Nov 2015 13:17:49 -0500 (EST)
Message-ID: <20151107.131749.1683961316470551613.davem@davemloft.net>
References: <1446819931-60897-1-git-send-email-jarod@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Dept-GELinuxNICDev@qlogic.com,
	netdev@vger.kernel.org, manish.chopra@qlogic.com
To: jarod@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1446819931-60897-1-git-send-email-jarod@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jarod Wilson <jarod@redhat.com>
Date: Fri,  6 Nov 2015 09:25:31 -0500

> The bonding driver saves a copy of slaves' original mac address and then
> assigns whatever mac as needed to the slave, depending on mode. In at
> least modes 5 and 6 (balance-tlb, balance-alb), it often ends up being the
> mac address of another slave. On release from the bond, the original mac
> address is supposed to get restored via a dev_set_mac_address() call in
> the bonding driver's __bond_release_one() function, which calls the
> slave's ndo_set_mac_address function, which for qlcnic, is
> qlcnic_set_mac().
> 
> Now, this function tries to be somewhat intelligent and exit early if
> you're trying to set the mac address to the same thing that is already
> set. The problem here is that adapter->mac_addr isn't in sync with
> netdev->dev_addr. The qlcnic driver still has the original mac stored in
> adapter->mac_addr, while the bonding driver has updated netdev->dev_addr,
> so qlcnic thinks we're trying to set the same address it already has.
> 
> I think the way to go here, since the function updates both netdev and
> adapter's stored mac addresses, is to check if either of them doesn't
> match the newly requested mac. Simply checking netdev's value only could
> result in a similar mismatch and non-update, so look at both.
> 
> CC: Dept-GELinuxNICDev@qlogic.com
> CC: netdev@vger.kernel.org
> CC: Manish Chopra <manish.chopra@qlogic.com>
> Signed-off-by: Jarod Wilson <jarod@redhat.com>

Applied.
