From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v6 0/2] bridge: make setlink/dellink
 notifications more accurate
Date: Sun, 29 Oct 2017 11:04:05 +0900 (KST)
Message-ID: <20171029.110405.363445271511169384.davem@davemloft.net>
References: <1f6df7e3-cd05-9b96-9f45-49c433011ff2@cumulusnetworks.com>
	<1509099577-5959-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	bridge@lists.linux-foundation.org, mrv@mojatatu.com,
	dsa@cumulusnetworks.com
To: nikolay@cumulusnetworks.com
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1509099577-5959-1-git-send-email-nikolay@cumulusnetworks.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Date: Fri, 27 Oct 2017 13:19:35 +0300

> Before this set the bridge would generate a notification on vlan add or del
> even if they didn't actually do any changes, which confuses listeners and
> is generally not preferred. We could also lose notifications on actual
> changes if one adds a range of vlans and there's an error in the middle.
> The problem with just breaking and returning an error is that we could
> break existing user-space scripts which rely on the vlan delete to clear
> all existing entries in the specified range and ignore the non-existing
> errors (typically used to clear the current vlan config).
> So in order to make the notifications more accurate while keeping backwards
> compatibility we add a boolean that tracks if anything actually changed
> during the config calls.
> 
> The vlan add is more difficult to fix because it always returns 0 even if
> nothing changed, but we cannot use a specific error because the drivers
> can return anything and we may mask it, also we'd need to update all places
> that directly return the add result, thus to signal that a vlan was created
> or updated and in order not to break overlapping vlan range add we pass
> down the new boolean that tracks changes to the add functions to check
> if anything was actually updated.
> 
> v6: moved "changed" in else branch in br|nbp_vlan_add, thanks to
>     Toshiaki Makita and retested everything again
> v5: fix br_vlan_add return (v1 leftover) spotted by Toshiaki Makita
> v4: set changed always to false in the non-vlan config case and retested
> v3: rebased to latest net-next and fixed non-vlan config functions reported
>     by kbuild test bot
> v2: pass changed down to vlan add instead of masking errors

Series applied, thank you.
