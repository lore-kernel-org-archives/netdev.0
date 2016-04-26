From: "David Rivshin (Allworx)" <drivshin.allworx@gmail.com>
Subject: Re: [PATCH net v2 1/3] drivers: net: cpsw: fix parsing of
 phy-handle DT property in dual_emac config
Date: Tue, 26 Apr 2016 11:27:09 -0400
Message-ID: <20160426112709.1894877b.drivshin.allworx@gmail.com>
References: <1461261035-5578-1-git-send-email-drivshin.allworx@gmail.com>
 <1461262794-9562-1-git-send-email-drivshin.allworx@gmail.com>
 <571A210E.2020607@ti.com>
 <571E6C7F.10704@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-omap@vger.kernel.org>,
	Mugunthan V N <mugunthanvnm@ti.com>
To: Grygorii Strashko <grygorii.strashko@ti.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f66.google.com ([209.85.192.66]:32833 "EHLO
	mail-qg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751101AbcDZP1O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2016 11:27:14 -0400
In-Reply-To: <571E6C7F.10704@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 25 Apr 2016 22:14:07 +0300
Grygorii Strashko <grygorii.strashko@ti.com> wrote:

> On 04/22/2016 04:03 PM, Grygorii Strashko wrote:
> > On 04/21/2016 09:19 PM, David Rivshin (Allworx) wrote:  
> >> From: David Rivshin <drivshin@allworx.com>
> >>
> >> Commit 9e42f715264ff158478fa30eaed847f6e131366b ("drivers: net: cpsw: add
> >> phy-handle parsing") saved the "phy-handle" phandle into a new cpsw_priv
> >> field. However, phy connections are per-slave, so the phy_node field 
> >> should
> >> be in cpsw_slave_data rather than cpsw_priv.
> >>
> >> This would go unnoticed in a single emac configuration. But in dual_emac
> >> mode, the last "phy-handle" property parsed for either slave would be 
> >> used
> >> by both of them, causing them both to refer to the same phy_device.
> >>
> >> Fixes: 9e42f715264f ("drivers: net: cpsw: add phy-handle parsing")
> >> Signed-off-by: David Rivshin <drivshin@allworx.com>
> >> Tested-by: Nicolas Chauvet <kwizart@gmail.com>
> >> ---
> >> I would suggest this for -stable. It should apply cleanly as far back
> >> as 4.4.
> >>
> >> Changes since v1 [1]:
> >> - Rebased (no conflicts)
> >> - Added Tested-by from Nicolas Chauvet
> >>
> >> [1] https://patchwork.ozlabs.org/patch/560326/  
> > 
> > Reviewed-by: Grygorii Strashko <grygorii.strashko@ti.com>  
> 
> In my opinion, it will be good to have this patch merged as part of -rc cycle, since
> it will fix "NULL pointer dereference" issue with current LKML as reported by Andrew Goodbody.

Dave, 
If you'd like to take just this first patch while enhancements for patch 2
are worked out, I'd have no problem with that. I would then just submit the 
rest of the series separately. If I don't see that you've taken this by the
time I have a V3 ready I'll include it again, but it will be unchanged and 
you can still take it separately if you wish. Or I can resubmit this patch
separately if you prefer.

(FYI, I tried to send this multiple times last night, but gmail has not 
been my friend lately. I ended up having to trim the CC list substantially
just to get this out at all; apologies for that. Suggestions for other 
email providers that are usable for patch submissions are welcome.)
