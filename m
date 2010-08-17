From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: linux-next: manual merge of the wireless tree with Linus' tree
Date: Tue, 17 Aug 2010 12:29:44 +0930
Message-ID: <201008171229.46175.rusty@rustcorp.com.au>
References: <20100817115203.e8a76e44.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, Dan Williams <dcbw@redhat.com>,
	libertas-dev@lists.infradead.org, netdev@vger.kernel.org,
	Takashi Iwai <tiwai@suse.de>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20100817115203.e8a76e44.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 17 Aug 2010 11:22:03 am Stephen Rothwell wrote:
> Hi John,
> 
> Today's linux-next merge of the wireless tree got a conflict in
> drivers/net/wireless/libertas/if_sdio.c between commit
> 886275ce41a9751117367fb387ed171049eb6148 ("param: lock if_sdio's
> lbs_helper_name and lbs_fw_name against sysfs changes") from Linus' tree
> and commit 3d32a58b87cd251b50842f93b87d5458061c0cfc ("libertas: [sdio]
> use common firmware request helper and new firmware locations") from the
> wireless tree.
> 
> OK, I can't quite figure out what is going on here.  The latter commit
> removes that code that was modified by the former, so I effectively
> reverted the former commit (by using this file from the wireless tree)
> since the "helper" and "firmware" fields of struct if_sdio_card don't
> seem to be used anywhere anymore.  Can they be removed as well?

I'm looking at the wireless tree now.

You can drop the commit as you have done.  But it leaves three problematic
writable charp parameters in the libertas/ directory which now need lifetime
management.

ie. kparam_block_sysfs_write()/unblock around them, and probably they need
to be copied.

Cheers,
Rusty.
