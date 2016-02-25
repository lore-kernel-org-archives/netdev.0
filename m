From: Li RongQing <roy.qing.li@gmail.com>
Subject: Re: [PATCH][net-next][v2] bridge: allow the maximum mtu to 64k
Date: Thu, 25 Feb 2016 09:50:41 +0800
Message-ID: <CAJFZqHwiJiMnEvq9mWZJqPbsm_VkDLPxMkgLt-UtwUTynA1RKQ@mail.gmail.com>
References: <1456189256-7811-1-git-send-email-roy.qing.li@gmail.com>
	<20160224134456.3ea94f0a@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f177.google.com ([209.85.214.177]:36053 "EHLO
	mail-ob0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751270AbcBYBum (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2016 20:50:42 -0500
Received: by mail-ob0-f177.google.com with SMTP id gc3so35575010obb.3
        for <netdev@vger.kernel.org>; Wed, 24 Feb 2016 17:50:41 -0800 (PST)
In-Reply-To: <20160224134456.3ea94f0a@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 25, 2016 at 5:44 AM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
>> This is especially annoying for the virtualization case because the
>> KVM's tap driver will by default adopt the bridge's MTU on startup
>> making it impossible (without the workaround) to use a large MTU on the
>> guest VMs.
>>
>> https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1399064
>
> This use case looks like KVM misusing bridge MTU. I.e it should set TAP
> MTU to what it wants then enslave it, not vice versa.

1. a use should be able to configure an empty bridge MTU to a higher
mtu than 1500

2. if first configure the tap MTU a higher value, other port is lower
value, the pmtu
will be used, it maybe lower performance.
the configuration process is written into libvirt, located in
virnetdevtap.c, of cause it can
be improved to fix this issue.
https://www.redhat.com/archives/libvir-list/2008-December/msg00083.html

-R
