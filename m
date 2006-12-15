From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 03/14] e1000: omit stats for broken counter in 82543
Date: Fri, 15 Dec 2006 09:50:23 -0500
Message-ID: <4582B62F.9020705@garzik.org>
References: <1166174907.3365.108.camel@laptopd505.fenrus.org> <1166175100.3365.115.camel@laptopd505.fenrus.org> <4582B17D.3070500@garzik.org> <4582B21F.8090907@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Kok, Auke" <auke-jan.h.kok@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:55330 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752659AbWLOOuZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Dec 2006 09:50:25 -0500
To: Arjan van de Ven <arjan@linux.intel.com>
In-Reply-To: <4582B21F.8090907@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arjan van de Ven wrote:
> Jeff Garzik wrote:
>> Needs to use an "i have broken stats" feature flag, rather than adding 
>> yet another mac_type test into the code.  This testing of MAC type 
>> rather than feature flags is a major e1000 problem, and it bloats the 
>> driver quite a bit.  Intel has been told for /months/ this is a 
>> problem, yet I still see patches like this.
>>
> it is "nice" that you say this, and Intel is working on a "flags" based 
> driver. However that is, as you state yourself here, a major invasive 
> change, and thus not suitable for 2.6.20 inclusion. Yet these fixes are 
> important bugfixes; I don't think it's fair to hold these hostage..

Completely false.  I /never/ said it was a major invasive change.

The following is obviously /not/ an invasive change, but rather a simple 
incremental approach:

1) Define "unsigned long flags" in your adapter struct
(only has to be done once)

2) For the management patch (patch #3?), define a flag 
E1000_FLG_I_HAVE_MGMT.

3) Set this flag everywhere patch #3 does a mac_type test.  Appears to 
be 2-4 locations TOUCHED BY THE PATCH ANYWAY.

4) Watch the patch get applied.

Shall I do this for Intel, since this has been explained multiple times 
without success?  This is not an invasive approach, it only touches what 
code you were touching anyway.


A WORD OF WARNING:  I am also highly suspicious of impending driver 
rewrites.  Such massive events inevitably break 'git bisect'.  A far 
better approach is the Al Viro equivalent-transformation approach, which 
does not break 'git bisect' and can be easily verified by a human.

	Jeff



