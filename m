From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: Re: [PATCH net-next 2/2] liquidio: Add support to create management
 interface
Date: Tue, 18 Jul 2017 11:58:27 -0700
Message-ID: <20170718115827.7bd737f2@cakuba.netronome.com>
References: <20170717195046.GA1191@felix-thinkpad.cavium.com>
        <20170717195217.GA1222@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        raghu.vatsavayi@cavium.com, derek.chickles@cavium.com,
        satananda.burla@cavium.com, veerasenareddy.burru@cavium.com
To: Felix Manlunas <felix.manlunas@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f52.google.com ([74.125.83.52]:34643 "EHLO
        mail-pg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751392AbdGRS6b (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Jul 2017 14:58:31 -0400
Received: by mail-pg0-f52.google.com with SMTP id 123so17490615pgj.1
        for <netdev@vger.kernel.org>; Tue, 18 Jul 2017 11:58:30 -0700 (PDT)
In-Reply-To: <20170717195217.GA1222@felix-thinkpad.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 17 Jul 2017 12:52:17 -0700, Felix Manlunas wrote:
> From: VSR Burru <veerasenareddy.burru@cavium.com>
> 
> This patch adds support to create a virtual ethernet interface to
> communicate with Linux on LiquidIO adapter for management.
> 
> Signed-off-by: VSR Burru <veerasenareddy.burru@cavium.com>
> Signed-off-by: Srinivasa Jampala <Srinivasa.Jampala@cavium.com>
> Signed-off-by: Satanand Burla <satananda.burla@cavium.com>
> Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@cavium.com>
> Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>

Not my call, but I have mixed feelings about this one.  Is there any
precedent under drivers/net/ethernet of exposing special communication
channels with FW like this?  It's irrelevant to me that you're running
SSH, arbitrary communication with FW from userspace is not something
netdev community usually accepts.  And I'm afraid what the effects will
be of this getting accepted.  I'm pretty sure most modern network
adapters have management CPU cores perfectly capable of running Linux.
I know NFP does, here is the out-of-tree code equivalent to this patch:

https://github.com/Netronome/nfp-drv-kmods/blob/master/src/nfpcore/nfp_net_vnic.c

I'm not looking forward to a world where I have to ssh into my NIC and
run vendor commands to configure things.
