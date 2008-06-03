From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 3/12] BE NIC driver - net_object i/f functions, Makefile
Date: Tue, 3 Jun 2008 10:02:15 -0700
Message-ID: <20080603100215.5789bf06@extreme>
References: <20080603094046.28f72fb5@mailhost.serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Subbu Seetharaman" <subbus@serverengines.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:34339 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752079AbYFCRCU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Jun 2008 13:02:20 -0400
In-Reply-To: <20080603094046.28f72fb5@mailhost.serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> +/*
> +
> +@file
> +    bni.c
> +
> +@brief
> +    This file contains finctions that will be used by the BladeEngine
> +    Network drivers to access BladeEngine Hardware. All code in
> +    this file must be completely OS neutral.
> +
> +*/
> +
> +#include "bni.h"
> +
> +/*!
> +   This function initializes the data structures in BNI / BECLIB for network
> +   operation.  The OSM driver must call this function before making any other
> +   BNI call.
> +
> +   If this functions succeeds, the caller must call bni_cleanup() as part
> +   of driver cleanup procedure.
> +
> +@param
> +    chipobj      -  Address of the space allocated by OSM for chip object
> +			(struct be_chip_object).  The space for this is
> +			allocated by OSM, but this object is maintained
> +			by BECLIB and is opaque to OSM.
> +@return
> +    BESTATUS - (0 if successful, non-zero status code if not successful)
> +
> + */


You commenting standard is similar but not compatiable with kernel docboock.
But I don't consider this a blocker to inclusion, just a nuisance.


> +BESTATUS bni_init(struct be_chip_object *chipobj)
> +{
> +	int r;
> +	r = be_initialize_library();
> +	if (r != BE_SUCCESS)
> +		goto error;
> +	r = be_chip_object_create(chipobj);
> +	if (r != BE_SUCCESS)
> +		goto error;
> +error:
> +	return (r);
> +}



But this overly verbose code style is the style of code which should be cleaned
up (after inclusion). It is the reason that kernel developers hate drivers that
try to be OS independent. They end up looking like the kind of rubbish written
by contracting software houses that are paid by the line of code.
