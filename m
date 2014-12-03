From: Jeremiah Mahler <jmmahler@gmail.com>
Subject: Re: linux-next: manual merge of the driver-core tree with the
 net-next tree
Date: Wed, 3 Dec 2014 00:36:55 -0800
Message-ID: <20141203083655.GA5418@hudson.localdomain>
References: <20141201181933.6dfaad66@canb.auug.org.au>
 <547C19ED.10201@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Rothwell <sfr@canb.auug.org.au>, Greg KH <greg@kroah.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Felix Fietkau <nbd@openwrt.org>,
	Ben Greear <greearb@candelatech.com>
To: Arend van Spriel <arend@broadcom.com>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <547C19ED.10201@broadcom.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

all,

On Mon, Dec 01, 2014 at 08:34:05AM +0100, Arend van Spriel wrote:
> On 01-12-14 08:19, Stephen Rothwell wrote:
> > Hi Greg,
> > 
> > Today's linux-next merge of the driver-core tree got a conflict in
> > drivers/net/wireless/ath/ath9k/debug.c between commits 70e535ed0029
> > ("ath9k: clean up debugfs print of reset causes"), 7b8aaead958e
> > ("ath9k: restart hardware after noise floor calibration failure") and
> > 325e18817668 ("ath9k: fix misc debugfs when not using chan context")
> > from the net-next tree and commit 631bee257bd5 ("ath: use seq_file api
> > for ath9k debugfs files") from the driver-core tree.
> > 
> > I fixed it up (see below) and can carry the fix as necessary (no action
> > is required).
> > 
> > Greg, I am not sure why those 2 commits are even in your tree.  Do they
> > depend on something else in your tree?
> 
> They do. The three commits below are related:
> 
> d32394f ath: ath9k: use debugfs_create_devm_seqfile() helper for
> seq_file entrie
> 631bee2 ath: use seq_file api for ath9k debugfs files
> 98210b7 debugfs: add helper function to create device related seq_file
> 
> The ath patches were made to provide example of using the new helper
> function and get some idea about code savings. Greg and John discussed
> who would take them. I noticed other ath changes in net-next so I kinda
> expected this email ;-)
> 
> Regards,
> Arend
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

I just ran in to a problem with one of these commits.

On an Acer C720 laptop if a suspend is performed the screen freezes,
the machine locks up, and according to the indicator lights it does
not enter suspend.  A hard reset is required to get it running again.

I have bisected the kernel and found that the following is the first bad
commit.

  commit d32394fae95741d733b174ec1446f27765f80233
  Author: Arend van Spriel <arend@broadcom.com>
  Date:   Sun Nov 9 11:32:00 2014 +0100
  
      ath: ath9k: use debugfs_create_devm_seqfile() helper for seq_file
  entries
      
      Use the helper to get rid of the file operations per debugfs file.
  The
      struct ath9k_softc pointer is set as device driver data to be
  obtained
      in the seq_file read operation.
      
      Signed-off-by: Arend van Spriel <arend@broadcom.com>
      Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

Let me know if I can do anything else to help.

-- 
- Jeremiah Mahler
