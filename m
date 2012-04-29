From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 6/6] tilegx network driver: initial support
Date: Sun, 29 Apr 2012 11:15:15 +0000
Message-ID: <201204291115.16127.arnd@arndb.de>
References: <201204062059.q36KxjEO011317@farm-0027.internal.tilera.com> <201204131034.03544.arnd@arndb.de> <4F9C6A0A.5090109@tilera.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Chris Metcalf <cmetcalf@tilera.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.171]:50270 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752208Ab2D2LPd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Apr 2012 07:15:33 -0400
In-Reply-To: <4F9C6A0A.5090109@tilera.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 28 April 2012, Chris Metcalf wrote:
> On 4/13/2012 6:34 AM, Arnd Bergmann wrote:
> > On Thursday 12 April 2012, Chris Metcalf wrote:
> >> On 4/10/2012 6:42 AM, Arnd Bergmann wrote:
> >>> Ok, but please remove tile_net_devs then.
> >>> I think a better abstraction for tile_net_devs_for_channel would be
> >>> some interface that lets you add private data to a channel so when
> >>> you get data from a channel, you can extract that pointer from the driver
> >>> using the channel.
> >> I think what would be clearer is to document how and why we are using this
> >> additional data structure.  We do access via both arrays where it is
> >> efficient to do so, so getting rid of either of them doesn't seem right. 
> 
> In the latest round of changes (to be mailed shortly), we eliminated one of
> the arrays entirely.  We now just have an array of net_device pointers
> indexed by channel, which we need since we get packets from the hardware
> and are only given the channel.  To get the device, we have to look it up
> in the array.
> 
> Since this is now the only array of net_device pointers, I eliminated the
> bychannel*() API I discussed in the previous email, since its use didn't
> seem as compelling any more.
> 
> >> Let's keep the "normal" tile_net_devs[] as is, indexed by devno, and make
> >> the tile_net_devs_for_channel[] more abstracted by using the following code:
> > The tile_net_devs still feels dirty. You basically only
> > use it in tile_net_handle_egress_timer(), but there you don't
> > actually take the mutex that protects addition and removal from
> > the array, so it's racy in case of hotplug.
> 
> We don't free the net_device structures themselves, so it's safe to do a
> lookup in the array and then dereference the net_device pointer even if we
> are doing an "ifconfig down" in another thread.  The only way you could
> imagine the net_device getting structures getting freed was via module
> unload, but it turns out that was pretty broken anyway, so I've just
> removed it altogether in the latest version of the patch.  So once you have
> a net_device pointer, it remains valid.

Ok, sounds all good then.

	Arnd
