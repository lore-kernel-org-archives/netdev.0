From: Baruch Siach <baruch@tkos.co.il>
Subject: Re: [PATCH 1/2] net: mvpp2: don't bring up on MAC address set
Date: Thu, 10 Nov 2016 20:08:15 +0200
Message-ID: <20161110180815.43zml2gjwkqq4utl@tarshish>
References: <ff17831771f3575f351c134703d3f153485b01c0.1478696194.git.baruch@tkos.co.il>
 <20161110.115718.1744727306693534849.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mw@semihalf.com, netdev@vger.kernel.org,
        thomas.petazzoni@free-electrons.com,
        gregory.clement@free-electrons.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from guitar.tcltek.co.il ([192.115.133.116]:53518 "EHLO
        mx.tkos.co.il" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752144AbcKJSIV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 10 Nov 2016 13:08:21 -0500
Content-Disposition: inline
In-Reply-To: <20161110.115718.1744727306693534849.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On Thu, Nov 10, 2016 at 11:57:18AM -0500, David Miller wrote:
> From: Baruch Siach <baruch@tkos.co.il>
> Date: Wed,  9 Nov 2016 14:56:33 +0200
> 
> > Current .ndo_set_mac_address implementation brings up the interface when revert
> > to original address after failure succeeds. Fix this.
> > 
> > Signed-off-by: Baruch Siach <baruch@tkos.co.il>
> > ---
> > Untested; I don't have the hardware.
> 
> The code which updates the parser should keep the existing
> state if any part of the update fails.
> 
> This means it must attempt all memory allocations and whatever other
> resource acquisition is necessary, and only after all of those
> operations succeed and no more error cases are possible should it
> update the tables and release the old entry.
> 
> In other worse, this whole mechanism must move to a proper "prepare
> --> commit" model of making changes.

Doing so is possible, but requires much larger changes in the driver code. 
This patch makes the minimal fix to a clear bug. It should be an improvement 
over the current state.

baruch

-- 
     http://baruch.siach.name/blog/                  ~. .~   Tk Open Systems
=}------------------------------------------------ooO--U--Ooo------------{=
   - baruch@tkos.co.il - tel: +972.52.368.4656, http://www.tkos.co.il -
