From: David Jander <david@protonic.nl>
Subject: gcc 4.8.3 miscompiles drivers/net/ethernet/freescale/fec_main.c ?!
Date: Wed, 10 Sep 2014 11:09:43 +0200
Message-ID: <20140910110943.3673dbb4@archvile>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: Russell King <rmk+kernel@arm.linux.org.uk>,
 "David S. Miller" <davem@davemloft.net>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
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


Hi,

I am seeing a strange problem when building a recent kernel with gcc-4.8.3 for
armv7-a that contains the following patch:

https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit?id=bfd4ecdd87d350e19457fe0d02fa1e046774c44e

Unfortunately I am not good enough at reading ARM assembly output from GCC to
understand whats going wrong, so I am asking for help.

I started noticing ethernet packet loss on a i.MX6 board after upgrading the
kernel from 3.16-rc-something to latest mainline. The problem is very easy to
reproduce so I started git-bisecting. Git bisect gave me the above patch as
the culprit, and indeed: Without the patch a flood-ping goes fine (just one
dot on screen, no lost packets). I apply the patch and the dots start filling
the screen instantly.

I am compiling the kernel using Pengutronix's OSELAS toolchain version
2013.12.1, which is based on linaro gcc-4.8.3 without any relevant patches
AFAIK.
Compiling with -O2 breaks the code, while -Os seems to produce a correctly
working kernel.

I decided to make changes to the code and see if I could find other ways to
"fix" the problem, and I got the following result:

The above mentioned patch introduces the static function fec_enet_hwtstamp()
near line 1068 of fec_main.c. If I make an exact copy of this function, where
I only change the name (e.g. fec_enet_hwtstamp2), and change one of the two
places this function is called to instead use the other name, GCC inlines both
copies and the problem disappears!

Since I am not very good at GCC internals nor do I know this piece of code in
fec_main.c very well, I am asking here for help in hunting down the real bug,
which I suspect is in GCC... but I want to know for sure.

Best regards,

-- 
David Jander
Protonic Holland.
