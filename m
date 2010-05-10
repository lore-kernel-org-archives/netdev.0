From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the rr tree with the net/wireless trees
Date: Mon, 10 May 2010 11:57:51 +1000
Message-ID: <20100510115751.fff295d8.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Steve deRosier <steve@cozybit.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Rusty,

Today's linux-next merge of the rr tree got a conflict in
drivers/net/wireless/libertas_tf/if_usb.c between commit
e9bd5bcde7af27ebb92bb866afde5ef5e4f3dc6c ("libertastf: add configurable
debug messages") from the net/wireless trees and commit
8e4920955f49d45b4df026611e3daef8ed570bf3 ("param:lock-charp-simple") from
the rr tree.

I fixed it up (see below) and can carry the fix as necessary.
-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/wireless/libertas_tf/if_usb.c
index 4412c27,5f27411..0000000
--- a/drivers/net/wireless/libertas_tf/if_usb.c
+++ b/drivers/net/wireless/libertas_tf/if_usb.c
@@@ -811,14 -651,15 +811,17 @@@ static int if_usb_prog_firmware(struct 
  	static int reset_count = 10;
  	int ret = 0;
  
 +	lbtf_deb_enter(LBTF_DEB_USB);
 +
+ 	kparam_block_sysfs_write(fw_name);
  	ret = request_firmware(&cardp->fw, lbtf_fw_name, &cardp->udev->dev);
  	if (ret < 0) {
 -		printk(KERN_INFO "libertastf: firmware %s not found\n",
 -		       lbtf_fw_name);
 +		pr_err("request_firmware() failed with %#x\n", ret);
 +		pr_err("firmware %s not found\n", lbtf_fw_name);
+ 		kparam_unblock_sysfs_write(fw_name);
  		goto done;
  	}
+ 	kparam_unblock_sysfs_write(fw_name);
  
  	if (check_fwfile_format(cardp->fw->data, cardp->fw->size))
  		goto release_fw;
