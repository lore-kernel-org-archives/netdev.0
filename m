From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC PATCH] vlan: Try to adjust lower device mtu when
 configuring 802.1AD vlans
Date: Wed, 2 Apr 2014 14:21:21 +0200
Message-ID: <20140402122121.GD26334@macbook.localnet>
References: <1396387054-4510-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:44583 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758456AbaDBMVY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2014 08:21:24 -0400
Content-Disposition: inline
In-Reply-To: <1396387054-4510-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 01, 2014 at 05:17:34PM -0400, Vlad Yasevich wrote:
> 802.1AD vlans supposed to encapsulate 802.1Q vlans.  To
> do this, we need an extra 4 bytes of header which are typically
> not accounted for by lower devices.  Some devices can not
> support frames longer then 1522 bytes at all.  Such devices
> can not really support 802.1AD, even in software, without
> the vlan reducing its mtu value.
> 
> This patch propses to increate the lower devices MTU to 1504
> in case of 802.1AD configuration, and if device doesn't
> support it, fail the creation of the vlan.  The user has an
> option to configure older-style Q-in-Q vlans and manually
> lower the mtu to support such encapsulation.

I think you should do the opposite. The lower layer device may be used
for other things than the VLAN, so it doesn't seem right to change it's
MTU. Instead I'd propose to set the MTU of the 802.1ad VLAN device to
the lower device'e MTU - 4 unless a MTU has been specified by the user.

BTW, I couldn't find anything related to MTU handling in the 802.1ad
standard, however I only have an old copy and might have looked in the
wrong place. Do you have any information how this is supposed to be
handled?
