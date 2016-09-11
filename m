From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [PATCH 00/26] constify local structures
Date: Sun, 11 Sep 2016 21:11:35 +0200 (CEST)
Message-ID: <alpine.DEB.2.10.1609112105250.3818@hadrien>
References: <1473599168-30561-1-git-send-email-Julia.Lawall@lip6.fr>
 <1473616576.19464.10.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: alsa-devel@alsa-project.org, Mustafa Ismail <mustafa.ismail@intel.com>,
 Tatyana Nikolova <tatyana.e.nikolova@intel.com>,
 kernel-janitors@vger.kernel.org, linux-fbdev@vger.kernel.org,
 platform-driver-x86@vger.kernel.org, devel@driverdev.osuosl.org,
 linux-scsi@vger.kernel.org, linux-rdma@vger.kernel.org,
 Jason Gunthorpe <jgunthorpe@obsidianresearch.com>, linux-acpi@vger.kernel.org,
 tpmdd-devel@lists.sourceforge.net, linux-media@vger.kernel.org,
 linux-pm@vger.kernel.org, linux-can@vger.kernel.org,
 Julia Lawall <Julia.Lawall@lip6.fr>, Shiraz Saleem <shiraz.saleem@intel.com>,
 Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, netdev@vger.kernel.org,
 Chien Tin Tung <chien.tin.tung@intel.com>, linux-wireless@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-spi@vger.kernel.org,
 linux-renesas-soc@vger.kernel.org, linux-usb@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1473616576.19464.10.camel@perches.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org


On Sun, 11 Sep 2016, Joe Perches wrote:

> On Sun, 2016-09-11 at 15:05 +0200, Julia Lawall wrote:
> > Constify local structures.
>
> Thanks Julia.
>
> A few suggestions & questions:
>
> Perhaps the script should go into scripts/coccinelle/
> so that future cases could be caught by the robot
> and commit message referenced by the patch instances.

OK.

> Can you please compile the files modified using the
> appropriate defconfig/allyesconfig and show the

I currently send patches for this issue only for files that compile using
the x86 allyesconfig.

> movement from data to const by using
> 	$ size <object>.new/old
> and include that in the changelogs (maybe next time)?

OK, thanks for the suggestion.

> Is it possible for a rule to trace the instances where
> an address of a struct or struct member is taken by
> locally defined and declared function call where the
> callee does not modify any dereferenced object?
>
> ie:
>
> struct foo {
> 	int bar;
> 	char *baz;
> };
>
> struct foo qux[] = {
> 	{ 1, "description 1" },
> 	{ 2, "dewcription 2" },
> 	[ n, "etc" ]...,
> };
>
> void message(struct foo *msg)
> {
> 	printk("%d %s\n", msg->bar, msg->baz);
> }
>
> where some code uses
>
> 	message(qux[index]);
>
> So could a coccinelle script change:
>
> struct foo qux[] = { to const struct foo quz[] = {
>
> and
>
> void message(struct foo *msg) to void message(const struct foo *msg)

Yes, this could be possible too.

Thanks for the feedback.

julia
