From: David Ahern <dsahern@gmail.com>
Subject: Re: Maximum MPLS labels on Linux network stack
Date: Wed, 3 May 2017 12:14:09 -0600
Message-ID: <5a408c23-d3e2-aa3e-4574-82521b2255b0@gmail.com>
References: <149211493832787@web33j.yandex.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
To: =?UTF-8?B?0JDQu9C10LrRgdC10Lkg0JHQvtC70LTRi9GA0LXQsg==?=
        <devel-net-ne-vlezay80@yandex.ru>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:36666 "EHLO
        mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752660AbdECSOO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 3 May 2017 14:14:14 -0400
Received: by mail-pf0-f182.google.com with SMTP id q66so16266893pfi.3
        for <netdev@vger.kernel.org>; Wed, 03 May 2017 11:14:13 -0700 (PDT)
In-Reply-To: <149211493832787@web33j.yandex.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/3/17 11:33 AM, Алексей Болдырев wrote:
> I watched one forum, there is listed in the properties of one license for Cisco, it says:
> 
> Layer 3 VPN • Multi-VRF CE (VRF-lite); requires IP Services Feature license
> • MPLS VPN; requires Advanced IP Feature license
> • 26 VRFs

There is no direct limit on the number of VRFs the kernel allows you to
create. There are indirect ones -- total memory in the system and limits
such as /proc/sys/net/ipv6/route/max_size. By increasing the latter I
have created 4k VRFs in a system.


> • 8192 MPLS labels 
> 
> Especially interested in the figure 8192 MPLS Labels.

8192 labels added in one pass is absurd. There is no reason to support
such a number. With the latest version of the MPLS stack in the kernel
you can add up to 30 labels in a single route. If you want more you have
to either recirculate the packet using routes or recompile the kernel
and increase the memory limit and the number of labels limit.

> 
> As I understand it, is it either a limit on the number of labels on the stack or the total number of labels?
> 
> In Linux, for example, you can specify a common col- lection of labels through /proc/sys/net/mpls/platforms_labels

that just allocates the size of an array which dictates the max label
number for that namespace. The array needs to be converted to a hash
table at some point.

> 
> Also I would like to know if the openvswitch has a limit of 3 tags in the stack or the total number of MPLS labels that can send?
> 

someone familiar with OVS needs to answer that.
