From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH next] xen: Convert printks to pr_<level>
Date: Fri, 28 Jun 2013 12:12:58 +0100
Message-ID: <1372417978.8976.123.camel@zakaz.uk.xensource.com>
References: <1372395469.2060.36.camel@joe-AO722>
	<20130628080250.GA16643@zion.uk.xensource.com>
	<1372414901.2060.44.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jeremy Fitzhardinge <jeremy@goop.org>, xen-devel@lists.xensource.com,
	Wei Liu <wei.liu2@citrix.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"virtualization@lists.osdl.org" <virtualization@lists.linux-foundation.org>
To: Joe Perches <joe@perches.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1372414901.2060.44.camel@joe-AO722>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Fri, 2013-06-28 at 03:21 -0700, Joe Perches wrote:
> Convert printks to pr_<level> (excludes printk(KERN_DEBUG...)
> to be more consistent throughout the xen subsystem.
> 
> Add pr_fmt with KBUILD_MODNAME or "xen:" KBUILD_MODNAME
> Coalesce formats and add missing word spaces
> Add missing newlines
> Align arguments and reflow to 80 columns
> Remove DRV_NAME from formats as pr_fmt adds the same content
> 
> This does change some of the prefixes of these messages
> but it also does make them more consistent.
> 
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
> 
> On Fri, 2013-06-28 at 09:02 +0100, Wei Liu wrote:
> > Do you also need to replace other printk occurences in xen-netback
> > directory, say, interface.c and xenbus.c?
> 
> Well, I don't _need_ to but if you want it

I think Wei just mean drivers/net/xen-blkback/{interface.c,xenbus.c} in
addition to the netback.c you were patching in your previous patch.

> this is what I suggest.

Wow ;-)

>  drivers/xen/balloon.c                       |  6 +++--
>  drivers/xen/cpu_hotplug.c                   |  6 +++--
>  drivers/xen/events.c                        | 23 +++++++++---------
>  drivers/xen/evtchn.c                        |  6 +++--
>  drivers/xen/gntalloc.c                      |  6 +++--
>  drivers/xen/gntdev.c                        |  8 ++++---
>  drivers/xen/grant-table.c                   | 17 +++++++-------
>  drivers/xen/manage.c                        | 23 +++++++++---------
>  drivers/xen/mcelog.c                        | 36 +++++++++++------------------
>  drivers/xen/pcpu.c                          | 12 +++++-----
>  drivers/xen/privcmd.c                       |  4 +++-
>  drivers/xen/swiotlb-xen.c                   | 12 ++++++----
>  drivers/xen/tmem.c                          | 10 ++++----
>  drivers/xen/xen-acpi-cpuhotplug.c           |  2 ++
>  drivers/xen/xen-acpi-memhotplug.c           |  2 ++
>  drivers/xen/xen-acpi-pad.c                  |  2 ++
>  drivers/xen/xen-acpi-processor.c            | 25 ++++++++++----------
>  drivers/xen/xen-balloon.c                   |  6 +++--
>  drivers/xen/xen-pciback/conf_space_header.c | 16 ++++++-------
>  drivers/xen/xen-pciback/pci_stub.c          | 25 +++++++++-----------
>  drivers/xen/xen-pciback/pciback_ops.c       |  9 +++++---
>  drivers/xen/xen-pciback/vpci.c              | 10 ++++----
>  drivers/xen/xen-pciback/xenbus.c            |  8 ++++---
>  drivers/xen/xen-selfballoon.c               | 11 ++++-----
>  drivers/xen/xenbus/xenbus_comms.c           | 13 ++++++-----
>  drivers/xen/xenbus/xenbus_dev_backend.c     |  4 +++-
>  drivers/xen/xenbus/xenbus_dev_frontend.c    |  4 +++-
>  drivers/xen/xenbus/xenbus_probe.c           | 30 +++++++++++-------------
>  drivers/xen/xenbus/xenbus_probe_backend.c   |  8 ++++---
>  drivers/xen/xenbus/xenbus_probe_frontend.c  | 35 ++++++++++++++--------------
>  drivers/xen/xenbus/xenbus_xs.c              | 22 ++++++++----------
>  drivers/xen/xencomm.c                       |  2 ++
>  drivers/xen/xenfs/super.c                   |  4 +++-
>  include/xen/hvm.h                           |  4 ++--
>  34 files changed, 215 insertions(+), 196 deletions(-)
