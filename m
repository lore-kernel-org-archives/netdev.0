From: Tomoki Sekiyama <tomoki.sekiyama@gmail.com>
Subject: Re: linux-next: manual merge of the bkl-llseek tree with the wireless tree
Date: Fri, 19 Nov 2010 13:50:00 +0900
Message-ID: <AANLkTinRBv00zo-=DWbZYZi7YQTvuF-t61_mk9txO-Bb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	"John W. Linville" <linville@tuxdriver.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Felix Fietkau <nbd@openwrt.org>,
	Linus <torvalds@linux-foundation.org>,
	Christoph Hellwig <hch@infradead.org>
To: Arnd Bergmann <arnd@arndb.de>, gregkh@suse.de
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Arnd,

On 2010-10-23 09:27:35, Arnd Bergmann wrote:
> On Saturday 23 October 2010, Stephen Rothwell wrote:
>> Hi John, Dave,
>>
>> On Mon, 18 Oct 2010 17:35:43 +1100 Stephen Rothwell<sfr@canb.auug.org.au>  wrote:
>>>
>>> Today's linux-next merge of the bkl-llseek tree got a conflict in
>>> drivers/net/wireless/ath/ath9k/debug.c between commit
>>> 772d5515635fef5bc7a9d0efee785b58b0181ee5 ("ath9k: make rate control
>>> debugfs stats per station") from the wireless tree and commit
>>> 6038f373a3dc1f1c26496e60b6c40b164716f07e ("llseek: automatically
>>> add .llseek fop") from the bkl-llseek tree.
<snip>
>> This patch (reproduced below) will now be needed if the wireless or net
>> tree is merged with Linus' tree.  I also think I have missed a similar
>> needed fix in drivers/net/wireless/ath/ath5k/debug.c ...
>
> There are also new drivers for speakup, intel_sst and yurex that introduce
> additional file_operations in next, the patch below is what I had planned
> to submit once everything is in. I also expect the occasional driver that
> did not see linux-next, so I'll rerun my scripts after -rc1 to see what
> we got.

Is your patch that adds .llseek fops planned to be merged to -rc?

The driver for yurex needs your patch that adds .llseek fop
(the hunk below) to work correctly. (tested in 2.6.36-rc2)

diff --git a/drivers/usb/misc/yurex.c b/drivers/usb/misc/yurex.c
index 719c618..ac5bfd6 100644
--- a/drivers/usb/misc/yurex.c
+++ b/drivers/usb/misc/yurex.c
@@ -536,6 +536,7 @@  static const struct file_operations yurex_fops = {
  	.open =		yurex_open,
  	.release =	yurex_release,
  	.fasync	=	yurex_fasync,
+	.llseek =	default_llseek,
  };


Thanks,
-- 
Tomoki Sekiyama
