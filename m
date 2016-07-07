From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] net/ixgbe: Allow resetting VF admin mac to zero
Date: Wed, 6 Jul 2016 20:57:21 -0700
Message-ID: <20160706205721.15eae36c@xeon-e3>
References: <1467364778-27198-1-git-send-email-juerg.haefliger@hpe.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com,
	linux-kernel@vger.kernel.org
To: Juerg Haefliger <juerg.haefliger@hpe.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:35527 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755951AbcGGD5K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jul 2016 23:57:10 -0400
Received: by mail-pa0-f52.google.com with SMTP id dx3so2367555pab.2
        for <netdev@vger.kernel.org>; Wed, 06 Jul 2016 20:57:09 -0700 (PDT)
In-Reply-To: <1467364778-27198-1-git-send-email-juerg.haefliger@hpe.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri,  1 Jul 2016 11:19:38 +0200
Juerg Haefliger <juerg.haefliger@hpe.com> wrote:

> The VF administrative mac addresses (stored in the PF driver) are
> initialized to zero when the PF driver starts up.
> 
> These addresses may be modified in the PF driver through ndo calls
> initiated by iproute2 or libvirt.
> 
> While we allow the PF/host to change the VF admin mac address from zero
> to a valid unicast mac, we do not allow restoring the VF admin mac to
> zero. We currently only allow changing this mac to a different unicast mac.
> 
> This leads to problems when libvirt scripts are used to deal with
> VF mac addresses, and libvirt attempts to revoke the mac so this
> host will not use it anymore.
> 
> Fix this by allowing resetting a VF administrative MAC back to zero.
> 
> Implementation and commit message shamelessly stolen from:
> commit 6e5224224faa ("net/mlx4_core: Allow resetting VF admin mac to zero")
> 
> Signed-off-by: Juerg Haefliger <juerg.haefliger@hpe.com>

Since set mac is allowed any time even when device is up, you must
prevent a a device that is in UP state from having all zero MAC address.
