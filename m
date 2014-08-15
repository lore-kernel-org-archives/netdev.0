From: Kevin Wilson <wkevils@gmail.com>
Subject: Re: BRIDGE_FLAGS_MASTER is used instead of BRIDGE_VLAN_INFO_MASTER
 flag in bridge/vlan.c
Date: Fri, 15 Aug 2014 11:22:12 +0300
Message-ID: <CAGXs5wVB4FPNRHQvgwYQkLgDCHm3xN+_uv0bmD1jGVxD804hmg@mail.gmail.com>
References: <CAGXs5wVPS6YdTsiPxj3aaiwHVSgUhiXtUHxFUNTKDUKxRKTD5A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Stephen Hemminger <stephen@networkplumber.org>, vyasevic@redhat.com
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f48.google.com ([209.85.218.48]:51315 "EHLO
	mail-oi0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751703AbaHOIWN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Aug 2014 04:22:13 -0400
Received: by mail-oi0-f48.google.com with SMTP id h136so1493807oig.35
        for <netdev@vger.kernel.org>; Fri, 15 Aug 2014 01:22:12 -0700 (PDT)
In-Reply-To: <CAGXs5wVPS6YdTsiPxj3aaiwHVSgUhiXtUHxFUNTKDUKxRKTD5A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

poke

On Wed, Aug 13, 2014 at 10:20 PM, Kevin Wilson <wkevils@gmail.com> wrote:
> Hello,
>
> The BRIDGE_VLAN_INFO_MASTER flag was added to /include/uapi/linux/if_bridge.h
> by commit 407af3299ef1ac7e87ce3fb530e32a009d1a9efd,
> "Add netlink interface to configure vlans on bridge ports".
> The value of this flag is checked in the kernel only in the br_afspec()
> method, net/bridge/br_netlink.c.
>
>
> Can someone please explain how and where is the BRIDGE_VLAN_INFO_MASTER
> flag set in userspace? I cannot find such a case. The natural place
> for it is bridge/vlan.c ?(of
> proute2), but it is not set there, and  not in any other module of iproute2.
> see:
> http://git.kernel.org/cgit/linux/kernel/git/shemminger/iproute2.git/tree/bridge/vlan.c
>
> There is another flag named "BRIDGE_FLAGS_MASTER" which is set in
> bridge/vlan.c of iproute2.
>
> Both these flags, BRIDGE_FLAGS_MASTER and BRIDGE_VLAN_INFO_MASTER,
> appear in include/linux/if_bridge.h in iproute2, and both have the
> value 1.
>
> Could it be a mistake, and in fact when setting BRIDGE_FLAGS_MASTER
> in bridge/vlan.c of iproute2, the meaning was to set
> BRIDGE_VLAN_INFO_MASTER (but since both there values are the same,
> it was not noticed since it caused no problem)? It
> seems to me that we do not really mean to set
> a bridge flag (BRIDGE_FLAGS_MASTER) in a vlan module.
> This mistake is the only explanation I can think of for why
> BRIDGE_VLAN_INFO_MASTER
> is not used in bridge/vlan.c of iproute2.
>
> If this is the case, I volunteer to send a patch to fix this
> by setting BRIDGE_VLAN_INFO_MASTER instead of BRIDGE_FLAGS_MASTER
> in bridge/vlan.c.
>
> Regards,
> Kevin
