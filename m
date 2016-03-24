From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: =?UTF-8?Q?Re=3A_veth_regression_with_=22don=E2=80=99t_modify_ip=5Fsummed=3B_?=
	=?UTF-8?Q?doing_so_treats_packets_with_bad_checksums_as_good=2E=22?=
Date: Thu, 24 Mar 2016 16:56:03 -0700
Message-ID: <CAM_iQpWv_iP1ZtsRQT0YsztMrf6rdaXN2V57PUu5oBe5kR56AQ@mail.gmail.com>
References: <56F463D6.7080406@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, Evan Jones <ej@evanjones.ca>,
	Vijay P <vijayp@vijayp.ca>, Cong Wang <cwang@twopensource.com>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f177.google.com ([209.85.161.177]:34750 "EHLO
	mail-yw0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750859AbcCXX4J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Mar 2016 19:56:09 -0400
Received: by mail-yw0-f177.google.com with SMTP id h129so80282793ywb.1
        for <netdev@vger.kernel.org>; Thu, 24 Mar 2016 16:56:04 -0700 (PDT)
In-Reply-To: <56F463D6.7080406@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 24, 2016 at 3:01 PM, Ben Greear <greearb@candelatech.com> wrote:
> I have an application that creates two pairs of veth devices.
>
> a <-> b       c <-> d
>
> b and c have a raw packet socket opened on them and I 'bridge' frames
> between b and c to provide network emulation (ie, configurable delay).
>

IIUC, you create two raw sockets in order to bridge these two veth pairs?
That is, to receive packets on one socket and deliver packets on the other?


>
> I put IP 1.1.1.1/24 on a, 1.1.1.2/24 on d, and then create a UDP connection
> (using policy based routing to ensure frames are sent on the appropriate
> interfaces).
>
> This is user-space only app, and kernel in this case is completely
> unmodified.
>
> The commit below breaks this feature:  UDP frames are sniffed on both a and
> d ports
> (in both directions), but the UDP socket does not receive frames.
>
> Using normal ethernet ports, this network emulation feature works fine, so
> it is
> specific to VETH.
>
> A similar test with just sending UDP between a single veth pair:  e <-> f
> works fine.  Maybe it has something to do with raw packets?
>

Yeah, I have the same feeling. Could you trace kfree_skb() to see
where these packets are dropped? At UDP layer?

Thanks.
