From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v9 1/4] net: add name_assign_type netdev attribute
Date: Tue, 15 Jul 2014 16:18:38 -0700 (PDT)
Message-ID: <20140715.161838.488578760446734001.davem@davemloft.net>
References: <1405348645-1995-1-git-send-email-teg@jklm.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: teg@jklm.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45479 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932908AbaGOXSj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2014 19:18:39 -0400
In-Reply-To: <1405348645-1995-1-git-send-email-teg@jklm.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Gundersen <teg@jklm.no>
Date: Mon, 14 Jul 2014 16:37:22 +0200

> Based on a patch by David Herrmann.
> 
> The name_assign_type attribute gives hints where the interface name of a
> given net-device comes from. These values are currently defined:
 ...
> The aim of these patches is to improve user-space renaming of interfaces. As
> a general rule, userspace must rename interfaces to guarantee that names stay
> the same every time a given piece of hardware appears (at boot, or when
> attaching it). However, there are several situations where userspace should
> not perform the renaming, and that depends on both the policy of the local
> admin, but crucially also on the nature of the current interface name.
> 
> If an interface was created in repsonse to a userspace request, and userspace
> already provided a name, we most probably want to leave that name alone. The
> main instance of this is wifi-P2P devices created over nl80211, which currently
> have a long-standing bug where they are getting renamed by udev. We label such
> names NET_NAME_USER.
> 
> If an interface, unbeknown to us, has already been renamed from userspace, we
> most probably want to leave also that alone. This will typically happen when
> third-party plugins (for instance to udev, but the interface is generic so could
> be from anywhere) renames the interface without informing udev about it. A
> typical situation is when you switch root from an installer or an initrd to the
> real system and the new instance of udev does not know what happened before
> the switch. These types of problems have caused repeated issues in the past. To
> solve this, once an interface has been renamed, its name is labelled
> NET_NAME_RENAMED.
> 
> In many cases, the kernel is actually able to name interfaces in such a
> way that there is no need for userspace to rename them. This is the case when
> the enumeration order of devices, or in fact any other (non-parent) device on
> the system, can not influence the name of the interface. Examples include
> statically created devices, or any naming schemes based on hardware properties
> of the interface. In this case the admin may prefer to use the kernel-provided
> names, and to make that possible we label such names NET_NAME_PREDICTABLE.
> We want the kernel to have tho possibilty of performing predictable interface
> naming itself (and exposing to userspace that it has), as the information
> necessary for a proper naming scheme for a certain class of devices may not
> be exposed to userspace.
> 
> The case where renaming is almost certainly desired, is when the kernel has
> given the interface a name using global device enumeration based on order of
> discovery (ethX, wlanY, etc). These naming schemes are labelled NET_NAME_ENUM.
> 
> Lastly, a fallback is left as NET_NAME_UNKNOWN, to indicate that a driver has
> not yet been ported. This is mostly useful as a transitionary measure, allowing
> us to label the various naming schemes bit by bit.
> 
> v8: minor documentation fixes
> v9: move comment to the right commit
> 
> Signed-off-by: Tom Gundersen <teg@jklm.no>
> Reviewed-by: David Herrmann <dh.herrmann@gmail.com>
> Reviewed-by: Kay Sievers <kay@vrfy.org>

Applied.
