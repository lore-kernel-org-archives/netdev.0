From: "Nelson, Shannon" <shannon.nelson@intel.com>
Subject: RE: [net-next 05/13] i40e: add range check to i40e_aq_rc_to_posix
Date: Tue, 9 Dec 2014 17:35:16 +0000
Message-ID: <FC41C24E35F18A40888AACA1A36F3E418ADB557F@fmsmsx115.amr.corp.intel.com>
References: <1418124170-7495-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1418124170-7495-6-git-send-email-jeffrey.t.kirsher@intel.com>
 <548705FC.6020805@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"nhorman@redhat.com" <nhorman@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"jogreene@redhat.com" <jogreene@redhat.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:56224 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751389AbaLISEJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 13:04:09 -0500
In-Reply-To: <548705FC.6020805@cogentembedded.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Sergei Shtylyov [mailto:sergei.shtylyov@cogentembedded.com]
> Sent: Tuesday, December 09, 2014 6:24 AM
> To: Kirsher, Jeffrey T; davem@davemloft.net
> Cc: Nelson, Shannon; netdev@vger.kernel.org; nhorman@redhat.com;
> sassmann@redhat.com; jogreene@redhat.com
> Subject: Re: [net-next 05/13] i40e: add range check to
> i40e_aq_rc_to_posix
> 
> Hello.
> 
> On 12/9/2014 2:22 PM, Jeff Kirsher wrote:
> 
> > From: Shannon Nelson <shannon.nelson@intel.com>
> 
> > Just to be sure, add a range check to avoid any possible
> > array index-out-of-bound issues.
> 
> > Change-ID: I9323bee6732c2a47599816e1d6c6b3a1f8dcbf54
> > Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
> > Acked-by: Michal Kosiarz <michal.kosiarz@intel.com>
> > Tested-by: Jim Young <jamesx.m.young@intel.com>
> > Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > ---
> >   drivers/net/ethernet/intel/i40e/i40e_adminq.h   | 2 ++
> >   drivers/net/ethernet/intel/i40evf/i40e_adminq.h | 2 ++
> >   2 files changed, 4 insertions(+)
> 
> > diff --git a/drivers/net/ethernet/intel/i40e/i40e_adminq.h
> b/drivers/net/ethernet/intel/i40e/i40e_adminq.h
> > index 618fe96..4064b1e 100644
> > --- a/drivers/net/ethernet/intel/i40e/i40e_adminq.h
> > +++ b/drivers/net/ethernet/intel/i40e/i40e_adminq.h
> > @@ -136,6 +136,8 @@ static inline int i40e_aq_rc_to_posix(u16 aq_rc)
> >   		-EFBIG,      /* I40E_AQ_RC_EFBIG */
> >   	};
> >
> > +	if (aq_rc >= (sizeof(aq_to_posix) / sizeof((aq_to_posix)[0])))
> 
>     There's ARRAY_SIZE() macro exactly for such computations. And parens
> around the last 'aq_to_posix' are not needed.

Yep, you're right.  I'll see about getting Jeff to push a v2 of this patch soon.

Thanks,
sln
