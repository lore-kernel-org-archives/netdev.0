From: Paul Mundt <lethal@linux-sh.org>
Subject: Re: drivers/net/ax88796.c compile error on sh64
Date: Sun, 11 Nov 2007 18:36:26 +0900
Message-ID: <20071111093625.GA25796@linux-sh.org>
References: <20071111090620.GK21669@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linuxsh-dev@lists.sourceforge.net,
	Magnus Damm <damm@igel.co.jp>,
	linuxsh-shmedia-dev@lists.sourceforge.net
To: Adrian Bunk <bunk@kernel.org>
Return-path: <linuxsh-dev-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <20071111090620.GK21669@stusta.de>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linuxsh-dev>,
	<mailto:linuxsh-dev-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linuxsh-dev>
List-Post: <mailto:linuxsh-dev@lists.sourceforge.net>
List-Help: <mailto:linuxsh-dev-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linuxsh-dev>,
	<mailto:linuxsh-dev-request@lists.sourceforge.net?subject=subscribe>
Sender: linuxsh-dev-bounces@lists.sourceforge.net
Errors-To: linuxsh-dev-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Sun, Nov 11, 2007 at 10:06:21AM +0100, Adrian Bunk wrote:
> Commit 8687991a734a67f1638782c968f46fff0f94bb1f causes the following 
> compile error on sh64:
> 
> <--  snip  -->
> 
> ...
>   CC [M]  drivers/net/ax88796.o
> /home/bunk/linux/kernel-2.6/git/linux-2.6/drivers/net/ax88796.c: In function 'ax_get_8390_hdr':
> /home/bunk/linux/kernel-2.6/git/linux-2.6/drivers/net/ax88796.c:187: error: implicit declaration of function 'readsw'
> /home/bunk/linux/kernel-2.6/git/linux-2.6/drivers/net/ax88796.c:189: error: implicit declaration of function 'readsb'
> /home/bunk/linux/kernel-2.6/git/linux-2.6/drivers/net/ax88796.c: In function 'ax_block_output':
> /home/bunk/linux/kernel-2.6/git/linux-2.6/drivers/net/ax88796.c:275: error: implicit declaration of function 'writesw'
> /home/bunk/linux/kernel-2.6/git/linux-2.6/drivers/net/ax88796.c:277: error: implicit declaration of function 'writesb'
> make[3]: *** [drivers/net/ax88796.o] Error 1
> 
> <--  snip -->
> 
That's a pretty good argument for the PLAT_HAS_xxx stuff in the Kconfig
space. We could have a if (CONFIG_SUPERH && !CONFIG_SUPERH64) thing here,
but there's probably not much point. I'm planning on merging them in the
2.6.25 time period anyways, so adding a stop-gap solution to hide this
driver's visibility doesn't really seem like a worthwhile endeavour.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
