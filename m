From: "Will Deacon" <will.deacon@arm.com>
Subject: Re: [PATCH RFC 0/4] ARM/KGDB: Some fixes for SMP
	machines
Date: Thu, 8 Jul 2010 09:48:56 +0100
Message-ID: <45011.6204367534$1278578979@news.gmane.org>
References: <20100707171222.GA16448@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Russell King <linux@arm.linux.org.uk>,
	"David S. Miller" <davem@davemloft.net>,
	linux-arm-kernel@lists.infradead.org,
	Jason Wessel <jason.wessel@windriver.com>
To: "'Anton Vorontsov'" <cbouatmailru@gmail.com>,
	<kgdb-bugreport@lists.sourceforge.net>
Return-path: <kgdb-bugreport-bounces@lists.sourceforge.net>
In-Reply-To: <20100707171222.GA16448@oksana.dev.rtsoft.ru>
Content-Language: en-gb
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/kgdb-bugreport>,
	<mailto:kgdb-bugreport-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=kgdb-bugreport>
List-Post: <mailto:kgdb-bugreport@lists.sourceforge.net>
List-Help: <mailto:kgdb-bugreport-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/kgdb-bugreport>,
	<mailto:kgdb-bugreport-request@lists.sourceforge.net?subject=subscribe>
Errors-To: kgdb-bugreport-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Hi Anton,

> It appears that KGDB can easily hang SMP ARM machines.

Yep. As pointed out at:

http://lkml.org/lkml/2010/4/8/214

Commit ae6bf53e broke kgdb on SMP systems because it incorrectly assumes
that atomic_{inc,dec} imply barriers. Until this is fixed, it will never
work reliably on ARM. Try reverting the patch [this doesn't completely
resolve the situation, but it might help].

> 1. I'm testing with I/D caches disabled. With enabled caches,
>    ARMv6K still locks-up. I'll test ARMv7 soon, and will try
>    to debug cache issues on ARMv6K.

This patch might help if you're using the ARM11MPCore:

http://lists.infradead.org/pipermail/linux-arm-kernel/2010-May/016567.html

Hope that helps,

Will




------------------------------------------------------------------------------
This SF.net email is sponsored by Sprint
What will you do first with EVO, the first 4G phone?
Visit sprint.com/first -- http://p.sf.net/sfu/sprint-com-first
