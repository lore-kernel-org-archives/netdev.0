From: Greg Rose <gregory.v.rose@intel.com>
Subject: Re: New commands to configure IOV features
Date: Wed, 19 Sep 2012 08:53:06 -0700
Message-ID: <20120919085306.00006af9@unknown>
References: <5003DC9B.8000706@broadcom.com>
	<5005BD00.4090106@redhat.com>
	<5005D45D.1040302@genband.com>
	<20120717.141153.46613285253481776.davem@davemloft.net>
	<500978C7.5050004@genband.com>
	<50097FBD.9080202@redhat.com>
	<1342806146.2678.31.camel@bwh-desktop.uk.solarflarecom.com>
	<5009B186.6000806@genband.com>
	<1342814473.2678.65.camel@bwh-desktop.uk.solarflarecom.com>
	<5009ECDF.4090305@genband.com>
	<500D59BF.9040006@redhat.com>
	<500D6932.8090306@genband.com>
	<20120723113607.56ce7aaf@nehalam.linuxnetplumber.net>
	<C5551D9AAB213A418B7FD5E4A6F30A070C7D9DCD@ORSMSX106.amr.corp.intel.com>
	<5059A767.2090307@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ariel Elior <ariele@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>
To: Yuval Mintz <yuvalmin@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:28098 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755830Ab2ISPxN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Sep 2012 11:53:13 -0400
In-Reply-To: <5059A767.2090307@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 19 Sep 2012 14:07:19 +0300
Yuval Mintz <yuvalmin@broadcom.com> wrote:

> >>> Back to the original discussion though--has anyone got any ideas
> >>> about the best way to trigger runtime creation of VFs?  I don't
> >>> know what the binary APIs looks like, but via sysfs I could see
> >>> something like
> >>>
> >>> echo number_of_new_vfs_to_create >
> >>> /sys/bus/pci/devices/<address>/create_vfs
> >>>
> >>> Something else that occurred to me--is there buy-in from driver
> >>> maintainers?  I know the Intel ethernet drivers (what I'm most
> >>> familiar
> >>> with) would need to be substantially modified to support
> >>> on-the-fly addition of new vfs.  Currently they assume that the
> >>> number of vfs is known at module init time.
> >>
> >> Why couldn't rtnl_link_ops be used for this. It is already the
> >> preferred interface to create vlan's, bond devices, and other
> >> virtual devices? The one issue is that do the created VF's exist
> >> in kernel as devices or only visible to guest?
> > 
> > I would say that rtnl_link_ops are network oriented and not
> > appropriate for something like a storage controller or graphics
> > device, which are two other common SR-IOV capable devices.
> 
> Hi Dave,
> 
> We're currently fine-tuning our SRIOV support, which we will shortly
> send upstream.
> 
> We've encountered a problem though - all drivers currently supporting
> SRIOV do so with the usage of a module param: e.g., 'max_vfs' for
> ixgbe, 'num_vfs' for benet, etc.
> The SRIOV feature is disabled by default on all the drivers; it can
> only be enabled via usage of the module param.
> 
> We don't want the lack of SRIOV module param in the bnx2x driver to be
> the bottle-neck when we'll submit the SRIOV feature upstream, and we
> also don't want to enable SRIOV by default (following the same logic
> of other drivers; most users don't use SRIOV and it would strain their
> resources).
> 
> As we see it, there are several possible ways of solving the issue:
>  1. Use some network-tool (e.g., ethtool).
>  2. Implement a standard sysfs interface for PCIe devices, as SRIOV is
>     not solely network-related (this should be done via the PCI linux
>     tree).

I was not able to attend the Linux conference held at the end of August
myself but coworkers of mine here at Intel informed that method 2 here
seems to be the preferred approach.  Perhaps some folks who attended
the the conference can chime in with more specifics.

- Greg
LAN Access Division
Intel Corp.



>  3. Implement a module param in our bnx2x code.
> 
> We would like to know what's your preferred method for solving this
> issue, and to hear if you have another (better?) method by which we
> can add this kind of support.
> 
> Thanks,
> Yuval Mintz
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
