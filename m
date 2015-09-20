From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: sr-iov and bridges (mlx4)
Date: Sun, 20 Sep 2015 14:01:25 +0300
Message-ID: <CAJ3xEMg1HR+WfhUNMCu9mnXp6F9Vuw8=VkrUvcynAn3VWoP2Gw@mail.gmail.com>
References: <55FDF69F.6000105@colorado.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Matthew Monaco <Matthew.Monaco@colorado.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f176.google.com ([209.85.214.176]:32949 "EHLO
	mail-ob0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754991AbbITLBZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Sep 2015 07:01:25 -0400
Received: by obbbh8 with SMTP id bh8so65091663obb.0
        for <netdev@vger.kernel.org>; Sun, 20 Sep 2015 04:01:25 -0700 (PDT)
In-Reply-To: <55FDF69F.6000105@colorado.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 20, 2015 at 2:58 AM, Matthew Monaco
<Matthew.Monaco@colorado.edu> wrote:
[...]
> In all cases, VMs with SR-IOV work fine, IP on the host works fine, outbound
> DHCP from the virtio VMs work fine, but inbound frames are not making it back to
> the VM.
[...]
> Is there a know limitation of mixing SR-IOV and bridges in general? Does the
> SR-IOV switch specific to the mlx4 hardware not work well with linux bridges? ...?

It would be a bit hard for bridge based promiscuous environment to work OOB
for one of the functions (PF or VF) in SRIOV, this is generic issue,
and not related
to specific vendor.

You need to use the bridge (8) tool (part of iproute2) and add the P.V
VM MACs to
the PF interface as "self" see some slides  (21/22/23) from netdev 0.1
that deal with that
https://netdev01.org/docs/netdev_tutorial_bridge_makita_150213.pdf

Or.

It also possible to mark one bridge port (the PF) as non-promiscuous,
but I haven't
played with that myself yet (slide 32), so can't just send you doing it...
