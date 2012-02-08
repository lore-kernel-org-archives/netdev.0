From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: RE: [net 2/8] igb: fix vf lookup
Date: Wed, 8 Feb 2012 23:55:10 +0000
Message-ID: <C5551D9AAB213A418B7FD5E4A6F30A0702F862AE@ORSMSX106.amr.corp.intel.com>
References: <1328693798-27323-3-git-send-email-jeffrey.t.kirsher@intel.com>
	<C5551D9AAB213A418B7FD5E4A6F30A0702F86242@ORSMSX106.amr.corp.intel.com>
	<1328744980.6909.8.camel@joe2Laptop>
 <20120208.185244.1488314318862923939.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"stable@vger.kernel.org" <stable@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	"joe@perches.com" <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:57944 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757796Ab2BHXzR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2012 18:55:17 -0500
In-Reply-To: <20120208.185244.1488314318862923939.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Wednesday, February 08, 2012 3:53 PM
> To: joe@perches.com
> Cc: Rose, Gregory V; Kirsher, Jeffrey T; netdev@vger.kernel.org;
> gospo@redhat.com; sassmann@redhat.com; stable@vger.kernel.org
> Subject: Re: [net 2/8] igb: fix vf lookup
> 
> From: Joe Perches <joe@perches.com>
> Date: Wed, 08 Feb 2012 15:49:40 -0800
> 
> > On Wed, 2012-02-08 at 23:42 +0000, Rose, Gregory V wrote:
> >> > diff --git a/drivers/net/ethernet/intel/igb/igb_main.c
> > []
> >> > @@ -5012,7 +5012,8 @@ static int igb_find_enabled_vfs(struct
> igb_adapter
> >> > *adapter)
> >> >  	vf_devfn = pdev->devfn + 0x80;
> >> >  	pvfdev = pci_get_device(hw->vendor_id, device_id, NULL);
> >> >  	while (pvfdev) {
> >> > -		if (pvfdev->devfn == vf_devfn)
> >> > +		if (pvfdev->devfn == vf_devfn &&
> >> > +		    (pvfdev->bus->number >= pdev->bus->number))
> >> >  			vfs_found++;
> > []
> >> I'll fix this one too.  You start leaning on checkpatch and you get
> lazy I guess.
> >
> > I suppose an indentation rule could be created when
> > arguments on multiple lines don't align at the open
> > parenthesis, but I'm not going to rewrite emacs
> > indentation rules.
> >
> > Presumably it should only be used with --strict.
> >
> > Anyone think multiple line tests with inequivalent uses
> > of parentheses like this one should be noted as well?
> 
> Actually I thought this case was perfectly fine.

The imbalanced parenthesis usage bothers me.  And yes, if you're going to have a tool that checks patch formatting it'd be nice if it caught things like this.  But then I'm the lazy fool here...

- Greg
