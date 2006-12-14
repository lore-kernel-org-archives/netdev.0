From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [PATCH 4/4][SCTP]: Change adaption -> adaptation as per the
	latest API draft.
Date: Wed, 13 Dec 2006 17:38:52 -0800
Message-ID: <1166060332.4670.37.camel@w-sridhar2.beaverton.ibm.com>
References: <1166042692.4670.13.camel@w-sridhar2.beaverton.ibm.com>
	 <20061213.163554.63998920.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:54698 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751704AbWLNBjC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Dec 2006 20:39:02 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id kBE1d1ua018472
	for <netdev@vger.kernel.org>; Wed, 13 Dec 2006 20:39:01 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kBE1cwHP140322
	for <netdev@vger.kernel.org>; Wed, 13 Dec 2006 20:39:01 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kBE1cwLw010980
	for <netdev@vger.kernel.org>; Wed, 13 Dec 2006 20:38:58 -0500
To: David Miller <davem@davemloft.net>
In-Reply-To: <20061213.163554.63998920.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-12-13 at 16:35 -0800, David Miller wrote:
> From: Sridhar Samudrala <sri@us.ibm.com>
> Date: Wed, 13 Dec 2006 12:44:52 -0800
> 
> > diff --git a/include/linux/sctp.h b/include/linux/sctp.h
> > index 35108fe..d4f8656 100644
> > --- a/include/linux/sctp.h
> > +++ b/include/linux/sctp.h
> > @@ -180,7 +180,7 @@ typedef enum {
> >  	SCTP_PARAM_ERR_CAUSE		= __constant_htons(0xc003),
> >  	SCTP_PARAM_SET_PRIMARY		= __constant_htons(0xc004),
> >  	SCTP_PARAM_SUCCESS_REPORT	= __constant_htons(0xc005),
> > -	SCTP_PARAM_ADAPTION_LAYER_IND   = __constant_htons(0xc006),
> > +	SCTP_PARAM_ADAPTATION_LAYER_IND = __constant_htons(0xc006),
> >
> >  } sctp_param_t; /* enum */
> >
> 
> I don't care what the API draft says, you will break existing
> userspace applications by changing this define.
> 
> Please keep around a compatible define, and then add the new one.

These parameters are not used by user-space apps. They define the
parameters used by the protocol in SCTP headers that go on wire.

The kernel version of SCTP user-space API is present in
include/net/sctp/user.h and this patch does modify names of a socket
option, notification and fields in the associated structures.

But user-space should not use any SCTP kernel header files. It gets this
API via include/netinet/sctp.h that is included in lksctp-tools package.

This patch will not break any existing apps that use the
library/header-file from the released versions of lksctp-tools.

I will add compatible defines in the next release of lksctp-tools so
that it can be used with old apps as well as new apps that can use
the new names.

Thanks
Sridhar

