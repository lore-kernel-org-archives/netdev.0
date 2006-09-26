From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 09/11] b44: fix eeprom endianess issue
Date: Tue, 26 Sep 2006 12:08:42 -0400
Message-ID: <4519508A.4010004@garzik.org>
References: <200609252339.k8PNdNE4002654@shell0.pdx.osdl.net> <200609261747.25575.mb@bu3sch.de> <45194E60.4010701@garzik.org> <200609261804.37422.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Gary Zambrano <zambrano@broadcom.com>,
	akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:64902 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S932327AbWIZQIo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Sep 2006 12:08:44 -0400
To: Michael Buesch <mb@bu3sch.de>
In-Reply-To: <200609261804.37422.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Buesch wrote:
> No it isn't. There are lots of other parameters in the ssb SPROM.
> And most of them are _not_ in bigendian.
> I think we also read the PHYport or something in b44.
> See bcm43xx or the ssb module for the rest of the values.
> 
> Returning a SPROM bytearray as BABABABA is just plain wrong.
> It must always be ABABABAB, because we expect this. This patch
> encures ABABAB order on every platform. The interpret function
> must not know on which platform we are, as it's just interpreting
> the _byte_ array (byte array, without any endian semantics).
> 
> This _fixes_ a bug (In the correct way, so that future bugs will
> not appear)


It's amusing to call something incorrect, when my suggested solution 
will interpret the correct values from b44_get_invariants() simply by 
changing the b44_get_invariants() code from reading BABABABA to ABABABAB.

	Jeff


