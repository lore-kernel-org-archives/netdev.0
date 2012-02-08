From: Joe Perches <joe@perches.com>
Subject: RE: [net 2/8] igb: fix vf lookup
Date: Wed, 08 Feb 2012 15:49:40 -0800
Message-ID: <1328744980.6909.8.camel@joe2Laptop>
References: <1328693798-27323-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1328693798-27323-3-git-send-email-jeffrey.t.kirsher@intel.com>
	 <C5551D9AAB213A418B7FD5E4A6F30A0702F86242@ORSMSX106.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"stable@vger.kernel.org" <stable@vger.kernel.org>
To: "Rose, Gregory V" <gregory.v.rose@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:54778 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757671Ab2BHXtk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Feb 2012 18:49:40 -0500
In-Reply-To: <C5551D9AAB213A418B7FD5E4A6F30A0702F86242@ORSMSX106.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-02-08 at 23:42 +0000, Rose, Gregory V wrote:
> > diff --git a/drivers/net/ethernet/intel/igb/igb_main.c
[]
> > @@ -5012,7 +5012,8 @@ static int igb_find_enabled_vfs(struct igb_adapter
> > *adapter)
> >  	vf_devfn = pdev->devfn + 0x80;
> >  	pvfdev = pci_get_device(hw->vendor_id, device_id, NULL);
> >  	while (pvfdev) {
> > -		if (pvfdev->devfn == vf_devfn)
> > +		if (pvfdev->devfn == vf_devfn &&
> > +		    (pvfdev->bus->number >= pdev->bus->number))
> >  			vfs_found++;
[]
> I'll fix this one too.  You start leaning on checkpatch and you get lazy I guess.

I suppose an indentation rule could be created when
arguments on multiple lines don't align at the open
parenthesis, but I'm not going to rewrite emacs
indentation rules.

Presumably it should only be used with --strict.

Anyone think multiple line tests with inequivalent uses
of parentheses like this one should be noted as well?
