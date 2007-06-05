From: David Miller <davem@davemloft.net>
Subject: Re: [RFC RTNETLINK 00/09]: Netlink link creation API
Date: Tue, 05 Jun 2007 12:37:20 -0700 (PDT)
Message-ID: <20070605.123720.26278311.davem@davemloft.net>
References: <20070605141250.15650.47178.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, socketcan@hartkopp.net, hadi@cyberus.ca,
	xemul@sw.ru, ebiederm@xmission.com, tgraf@suug.ch
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48894
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1761967AbXFEThG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2007 15:37:06 -0400
In-Reply-To: <20070605141250.15650.47178.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Tue,  5 Jun 2007 16:12:51 +0200 (MEST)

> A few words about the API:
> 
> Drivers wishing to use the API register a struct rtnl_link_ops, which
> contains a few function pointers for device setup, registation, changing
> and deletion, as well as netlink attribute validation and device dumping.
> 
> All netlink communication happens within the AF_UNSPEC family. I
> initially introduced new netlink families for this, but removed them
> again since that would require adding new protocol families that serve
> no further purpose for most drivers. Additionally we currently use
> RTM.*LINK messages with ifi_family != AF_UNSPEC for information that
> is related to the device, but doesn't come from the driver that created
> the device itself, like bridge port state, IPv6 device configuration etc.
> 
> The device specific attributes are nested within a new attribute
> IFLA_LINKINFO. I didn't use IFLA_PROTINFO since userspace can reasonably
> expect to have IFLA_PROTINFO unset for AF_UNSPEC messages, and the
> userspace STP daemon does that. Identification of the driver happens
> by name, stored in the IFLA_INFO_NAME attribute. IFLA_INFO_DATA contains
> driver specific attributes, IFLA_INFO_XSTATS driver specific statistics.
> 
> The API does *not* use the existing RTM_SETLINK message type, instead
> it adds support for receiving RTM_NEWLINK within the kernel. I did this
> because of three reasons: 
> 
> - RTM_SETLINK does not follow the usual rtnetlink conventions and ignores
>   all netlink flags
> 
> - Other rtnetlink subsystems use the same message type for dumps and
>   notifications from the kernel as for configuration from userspace,
>   which usually allows to recreate an object by simply setting the
>   NLM_F_REQUEST flag on message received from the kernel and sending
>   it back.
> 
> - Easier for userspace to detect support for the new features
> 
> The RTM_NEWLINK message type is a superset of RTM_SETLINK, it allows
> to change both driver specific and generic attributes of the device.
> The set of generic device attributes that may be supplied during
> device creation is limited to a few simple ones, it currently does
> not support specifying link layer address/broadcast address as well
> as device flags. The change operation can change all device attributes.
> 
> Not sure what else to say .. comments welcome.

This excellent description of the APIs (particularly the background
and reasoning) belongs in a file under Documentation/networking/ :-)
