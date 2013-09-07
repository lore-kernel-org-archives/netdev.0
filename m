From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [net v6 1/8] i40e: main driver core
Date: Sat, 07 Sep 2013 08:44:36 +0200
Message-ID: <522ACB54.2050706@redhat.com>
References: <1378510875-10704-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1378510875-10704-2-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>, gospo@redhat.com,
	davem@davemloft.net, sassmann@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1378510875-10704-2-git-send-email-jeffrey.t.kirsher@intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

[...]
+i40e_status i40e_allocate_dma_mem_d(struct i40e_hw *hw,
+				    struct i40e_dma_mem *mem,
+				    u64 size, u32 alignment)
+{
+	struct i40e_pf *pf = (struct i40e_pf *)hw->back;
+
+	if (!mem)
+		return I40E_ERR_PARAM;
+
+	mem->size = ALIGN(size, alignment);
+	mem->va = dma_zalloc_coherent(&pf->pdev->dev, mem->size,
+				      &mem->pa, GFP_KERNEL);
+	if (mem->va)
+		return I40E_SUCCESS;
+
+	return I40E_ERR_NO_MEMORY;
+}

Nitpicking ... at some point in time i40e_status should be removed plus
I40E_ERR_PARAM, I40E_SUCCESS, I40E_ERR_NO_MEMORY and the like, as we have
int and -EINVAL, 0, -ENOMEM for that. ;-)

[...]
+i40e_status i40e_put_mac_in_vlan(struct i40e_vsi *vsi, u8 *macaddr,
+				 bool is_vf, bool is_netdev)
+{
+	struct i40e_mac_filter *f, *add_f;
+
+	list_for_each_entry(f, &vsi->mac_filter_list, list) {
[...]
+			if (!add_f) {
+				dev_info(&vsi->back->pdev->dev, "Could not add filter %d for %pM\n",
+					 f->vlan, f->macaddr);
+				return -ENOMEM;
+			}
+		}
+	}
+	return I40E_SUCCESS;
+}

Their usage seems also to be mixed anyway: -ENOMEM vs. I40E_SUCCESS.

[...]
+void i40e_vsi_reset_stats(struct i40e_vsi *vsi)
+{
+	struct rtnl_link_stats64 *ns;
+	int i;
+
+	if (!vsi)
+		return;
+
[...]
+static struct i40e_mac_filter *i40e_find_filter(struct i40e_vsi *vsi,
+						u8 *macaddr, s16 vlan,
+						bool is_vf, bool is_netdev)
+{
+	struct i40e_mac_filter *f;
+
+	if (!vsi || !macaddr)
+		return NULL;
[...]

Probably the code could also be scanned to remove such checks as well ...

------------------------------------------------------------------------------
Learn the latest--Visual Studio 2012, SharePoint 2013, SQL 2012, more!
Discover the easy way to master current and previous Microsoft technologies
and advance your career. Get an incredible 1,500+ hours of step-by-step
tutorial videos with LearnDevNow. Subscribe today and save!
http://pubads.g.doubleclick.net/gampad/clk?id=58041391&iu=/4140/ostg.clktrk
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
