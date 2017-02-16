From: jackm <jackm@dev.mellanox.co.il>
Subject: Re: Mellanox ConnectX-3 VF driver can't work with 16 CPUs?
Date: Thu, 16 Feb 2017 16:57:30 +0200
Message-ID: <20170216165730.00004b1b@dev.mellanox.co.il>
References: <MWHPR03MB2669F7138EE9DE92A372C863BF450@MWHPR03MB2669.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Yishai Hadas <yishaih@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Dexuan Cui <decui@microsoft.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f181.google.com ([209.85.128.181]:36330 "EHLO
        mail-wr0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932171AbdBPO5e (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2017 09:57:34 -0500
Received: by mail-wr0-f181.google.com with SMTP id 89so8872055wrr.3
        for <netdev@vger.kernel.org>; Thu, 16 Feb 2017 06:57:34 -0800 (PST)
In-Reply-To: <MWHPR03MB2669F7138EE9DE92A372C863BF450@MWHPR03MB2669.namprd03.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 9 Feb 2017 10:03:20 +0000
Dexuan Cui <decui@microsoft.com> wrote:

> Hi, 
> While trying SR-IOV with a Linux guest running on Hyper-V, I found
> this issue: the VF driver can't work if the guest has 16 virtual CPUs
> (less vCPUs, e.g. 8,  can work fine):
> 
> [    9.927820] mlx4_core: Mellanox ConnectX core driver v2.2-1 (Feb,
> 2014) [    9.927882] mlx4_core: Initializing b961:00:02.0
> [    9.970994] mlx4_core b961:00:02.0: Detected virtual function -
> running in slave mode [    9.976783] mlx4_core b961:00:02.0: Sending
> reset [    9.985858] mlx4_core b961:00:02.0: Sending vhcr0
> [   10.004855] mlx4_core b961:00:02.0: HCA minimum page size:512
> [   10.010465] mlx4_core b961:00:02.0: Timestamping is not supported
> in slave mode [   10.203065] mlx4_core b961:00:02.0: Failed to
> initialize event queue table, aborting [   10.226728] mlx4_core:
> probe of b961:00:02.0 failed with error -12
> 
> I'm using the mainline kernel (4.10.0-rc4).
> 
> Any idea?
> 
Thanks for reporting this, Dexuan.  We indeed found a bug in the Linux
driver, which requested too many EQEs per EQ created in SRIOV mode.
This resulted in the VF exhausting its supply of MTT entries.

We will submit an upstream fix for this soon (after thorough testing).

-Jack

> Thanks,
> -- Dexuan
> 
