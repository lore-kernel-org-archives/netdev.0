From: Kevin Wilson <wkevils@gmail.com>
Subject: GSO and IPv4 forwarding
Date: Tue, 26 Oct 2010 22:02:26 +0200
Message-ID: <AANLkTikxNYGFAmyZDit9fTp=-M8wfYp3Ew8rejsjHWHb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:61349 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760157Ab0JZUC1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Oct 2010 16:02:27 -0400
Received: by iwn10 with SMTP id 10so2551004iwn.19
        for <netdev@vger.kernel.org>; Tue, 26 Oct 2010 13:02:27 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
When we set a netdevice to support forwarding, we disable LRO.
This is done because we don't want to forward an SKB which has been
processed by LRO.

This is done in inet_forward_change() in net/ipv4/devinet.c:
We call dev_disable_lro(dev) in this method, when setting forwarding
for the device.
As a result, in ip_forward(), the packet will be dropped. (because
skb_warn_if_lro(), called by this method,  returns TRUE)

My question is:
dev_disable_lro(dev) disable the LRO feature (NETIF_F_LRO) of the
device. But suppose I have a device where GRO is enabled (and LRO is
not). And let's say I set forwarding on this device.

it seems to me that is such case, calling dev_disable_lro(dev)  in
net_forward_change() to disable the LRO feature of the device (which
is already disabled) is not enough, and in such case , GRO packets,
which want to be forwarded,  will **not** be dropped in ip_forward().
(since kb_warn_if_lro() will return false in this case)

Is it so ? I am ready to send a patch fixing it, but I am a newbie in
kernel, so I want to ask first.

rgs,
Kevin
