From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] liquidio: fix VF incorrectly indicating that
 it successfully set its VLAN
Date: Sat, 08 Apr 2017 08:39:05 -0700 (PDT)
Message-ID: <20170408.083905.1266827432475392554.davem@davemloft.net>
References: <20170407022222.GA1017@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com
To: felix.manlunas@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41366 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751137AbdDHPjH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 8 Apr 2017 11:39:07 -0400
In-Reply-To: <20170407022222.GA1017@felix-thinkpad.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Felix Manlunas <felix.manlunas@cavium.com>
Date: Thu, 6 Apr 2017 19:22:22 -0700

> For security reasons, NIC firmware does not allow VF to set its VLAN if PF
> set it already.  Firmware allows VF to set its VLAN if PF did not set it.
> After the VF instructs the firmware to set the VLAN, VF always indicates
> (via return 0) that the operation is successful--even for the times when it
> isn't.
> 
> Put in a mechanism for the VF's set VLAN function to receive the firmware
> response code, then make that function return -EPERM if the firmware
> forbids the operation.
> 
> Make that mechanism available for other functions that may, in the future,
> be interested in receiving the response code from the firmware.  That
> mechanism involves adding new fields to struct octnic_ctrl_pkt, so make all
> users of struct octnic_ctrl_pkt initialize the struct to zero before using
> it; otherwise, the mechanism might act on uninitialized garbage.
> 
> Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
> Signed-off-by: Derek Chickles <derek.chickles@cavium.com>

Applied, thanks.
