From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH 0/3] bridge: Some nice new things for vlan filtering
Date: Mon, 15 Sep 2014 09:24:05 -0700
Message-ID: <20140915092405.124ff9d0@urahara>
References: <1410554691-18467-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com,
	bridge@lists.linux-foundation.org,
	Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	Vladislav Yasevich <vyasevic@redhat.com>
To: Vladislav Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:47502 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753952AbaIOQYJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 12:24:09 -0400
Received: by mail-pa0-f45.google.com with SMTP id rd3so6839874pab.4
        for <netdev@vger.kernel.org>; Mon, 15 Sep 2014 09:24:09 -0700 (PDT)
In-Reply-To: <1410554691-18467-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 12 Sep 2014 16:44:48 -0400
Vladislav Yasevich <vyasevich@gmail.com> wrote:

> While working with vlan filtering and non-promisc mode, I've found
> myself wanting untagged traffic to automatically pass through the
> bridge.  So I decided to introduce the concept of a per bridge default
> pvid.  VLAN 1 is used as default pvid by default and can be changed
> by user through sysfs while vlan filtering is off. (I'll be adding netlink
> support now that Jiri Pirko kindly added the ifrastructure).  Default
> pvid is assigned to all ports that do not assign their own pvid or
> already have a given vlan configured.  This makes it very simple
> to enable vlan filtering on the bridge, not have to configure a thing,
> and still pass untagged traffic.
> 
> The other small thing this series adds is automatic update of the
> vlan filter when vlan is configured on top of the bridge.  In this
> case we automatically add the given vlan to the bridge filter list.
> The ports may still need to be updated as we don't know which ports
> are allowed to receive a given vlan.
> 
> Thanks
> -vlad
> 
> Vladislav Yasevich (3):
>   bridge: Add a default_pvid sysfs attribute
>   bridge: Add filtering support for default_pvid
>   bridge; Automatically filter vlans configured on top of bridge
> 
>  net/bridge/br_device.c   |  54 +++++++++++++++++++---
>  net/bridge/br_if.c       |   2 +
>  net/bridge/br_private.h  |  35 ++++++++++++++-
>  net/bridge/br_sysfs_br.c |  17 +++++++
>  net/bridge/br_vlan.c     | 113 ++++++++++++++++++++++++++++++++++++++++++++++-
>  5 files changed, 213 insertions(+), 8 deletions(-)
> 

Please, no special VLAN 1, other equipment has that silliness.

Why is untagged traffic not treated as VLAN 0?
