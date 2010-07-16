From: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
Subject: Re: Kexec Reboot Network Issue
Date: Fri, 16 Jul 2010 16:15:47 +0900
Message-ID: <20100716071547.GB20761@verge.net.au>
References: <4C3EF80B.1040400@symplicity.com>
	<20100715142003.GB19856@verge.net.au>
	<4C3F2ACF.60601@symplicity.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Matt Carlson <mcarlson-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	kexec-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, Michael Chan <mchan-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
To: Richard Genthner <rgenthner-2CkDue2ckGJOSnsfY10OVw@public.gmane.org>
Return-path: <kexec-bounces+glkk-kexec=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4C3F2ACF.60601-2CkDue2ckGJOSnsfY10OVw@public.gmane.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/kexec>,
	<mailto:kexec-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/kexec/>
List-Post: <mailto:kexec-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:kexec-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/kexec>,
	<mailto:kexec-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: kexec-bounces-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
Errors-To: kexec-bounces+glkk-kexec=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

[ CCed Michael Chan, Matt Carlson and Netdev ]

On Thu, Jul 15, 2010 at 11:35:43AM -0400, Richard Genthner wrote:
> On 07/15/2010 10:20 AM, Simon Horman wrote:
> >On Thu, Jul 15, 2010 at 07:59:07AM -0400, Richard Genthner wrote:
> >>I'm currently using the following string:
> >>
> >>kexex --type=elf-x86_64 --args-linux -l /boot/vmlinuz-2.6.18-12.el5
> >>--initrid=/boot/initrd-2.6.18-128.el6.img --append="`cat
> >>/proc/cmdline`"
> >>kexec -e
> >>
> >>Some times we can get to the box from any subnet, other times we can
> >>only get to the box from the same subnet only. Our solution to this
> >>is to down the iface and then restart networking. Has anyone else
> >>run into this issue?
> >Hi Richard,
> >
> >could you be more specific about which NIC you are using?
> >And is it at all possible to test a newer kernel version?
> >
> >What I suspect is happening is that the NIC is getting into an unknown
> >state. And what I'm hoping is that is a problem thats already been
> >addressed.
>
> I would try a different kenerl but our cluster fs has us locked to
> this kernel until we finish the upgrade to the new cluster fs
> version. heres ethtool on the iface
> 
> from lshw
> *-network
>                 description: Ethernet interface
>                 product: NetXtreme BCM5721 Gigabit Ethernet PCI Express
>                 vendor: Broadcom Corporation
>                 physical id: 0
>                 bus info: pci@0000:03:00.0
>                 logical name: eth0
>                 version: 21
>                 serial: 00:25:64:3b:9c:ae
>                 size: 1GB/s
>                 capacity: 1GB/s
>                 width: 64 bits
>                 clock: 33MHz
>                 capabilities: pm vpd msi pciexpress bus_master
> cap_list ethernet physical tp 10bt 10bt-fd 100bt 100bt-fd 1000bt
> 1000bt-fd autonegotiation
>                 configuration: autonegotiation=on broadcast=yes
> driver=tg3 driverversion=3.93 duplex=full firmware=5721-v3.65,
> ASFIPMI v6.25 ip=172.16.1.123 latency=0 link=yes module=tg3
> multicast=yes port=twisted pair speed=1GB/s

Hi Richard,

first, please don't top-post, its not the done thing in these parts.

I had a quick hunt through the git change log and the onl changed that
jumped out was "[TG3]: Fix msi issue with kexec/kdump"[1], but this
seems to have been back-ported to the initrd-2.6.18-128.el5 (I assume
you meant 5 not 6) kernel.

[1] http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=ee6a99b539a50b4e9398938a0a6d37f8bf911550

In any case I strongly suspect that the problem is a kernel problem and as
such can't be solved modifying the kernel or at least tg.ko module (which
is probably in the initrd). I suggest logging bug report with Red Hat.
