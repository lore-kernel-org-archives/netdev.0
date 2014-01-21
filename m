From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: issues with vxlan RX checksum offload under OVS datapath
Date: Tue, 21 Jan 2014 22:55:19 +0200
Message-ID: <CAJZOPZJ6xj=fOAY9rkXZZs99ONkHwcW8RMXb+H2FjJzV3eoAPg@mail.gmail.com>
References: <52DC4C1B.5000309@mellanox.com>
	<CALnjE+rUTejbU_d39G7WSn=k0aY2xELCE3UxjDr_Zdq3iwHbNA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	Joseph Gasparakis <joseph.gasparakis@intel.com>,
	netdev <netdev@vger.kernel.org>
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:50045 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750824AbaAUUzU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jan 2014 15:55:20 -0500
Received: by mail-pa0-f45.google.com with SMTP id lf10so6677960pab.32
        for <netdev@vger.kernel.org>; Tue, 21 Jan 2014 12:55:19 -0800 (PST)
In-Reply-To: <CALnjE+rUTejbU_d39G7WSn=k0aY2xELCE3UxjDr_Zdq3iwHbNA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 21, 2014 at 7:30 PM, Pravin Shelar <pshelar@nicira.com> wrote:
> On Sun, Jan 19, 2014 at 2:05 PM, Or Gerlitz <ogerlitz@mellanox.com> wrote:

>> While testing the gro udp patches over a setup with openvswitch I noted that
>> the RX checksum offload support introduced by Joseph's commit 0afb166
>> "vxlan: Add capability of Rx checksum offload for inner packet" works fine
>> when you use a setup made of
>> NIC --> IP stack --> vxlan device --> bridge --> tap
>> but not when its
>> NIC --> IP stack --> ovs vxlan port --> OVS DP --> tap
>> I narrowed it down to the fact the when going the OVS pathskb->encapsulation
>> remains true also after the decap is done. Basically, this is the original hunk
[...]
>>> +       skb->encapsulation = 0;
[...]

>> Moving this to shared code (while removing the check for
>> vxlan->dev->features) made things to work on my setup, but this misses one
>> of the original conditions, ideas?

> I kept csum check in vxlan-device recv path for same reason. As of now
> there is no efficient way to get ovs-dev features.
> May be we can cache device features in struct datapath from datapath-netdev.

To be a bit more precise/concrete here, do we agree that the both paths must do

   skb->encapsulation = 0;

which is done now only by the non-ovs path

Or.
