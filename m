From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH net] net/mlx4_core: Fix Oops on reboot when SRIOV VFs are
 probed into the Host
Date: Sun, 1 Jun 2014 22:59:59 +0300
Message-ID: <CAJZOPZJs8cS6fDdPNv07EeTO=dCOUxk5W5_YH+oagh6m5D5CLA@mail.gmail.com>
References: <1401619783-23659-1-git-send-email-ogerlitz@mellanox.com>
	<538B57BB.5090000@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Amir Vadai <amirv@mellanox.com>,
	Wei Yang <weiyang@linux.vnet.ibm.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f52.google.com ([209.85.216.52]:54776 "EHLO
	mail-qa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752271AbaFAUAA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jun 2014 16:00:00 -0400
Received: by mail-qa0-f52.google.com with SMTP id cm18so1630907qab.11
        for <netdev@vger.kernel.org>; Sun, 01 Jun 2014 12:59:59 -0700 (PDT)
In-Reply-To: <538B57BB.5090000@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 1, 2014 at 7:41 PM, Sergei Shtylyov
<sergei.shtylyov@cogentembedded.com> wrote:
> On 06/01/2014 02:49 PM, Or Gerlitz wrote:

>> Commit befdf89 did not take into account the case where the Host
>    Please also specify that commit's summary line in parens.

Did that below, see where we say

Fixes: befdf89 ("preserve pcd_dev_data after __mlx4_remove_one()")

>> driver is being unloaded. In this case, pci_get_drvdata for the VF
>> remove_one call may return NULL, so that dereferencing the priv
>> struct results in a kernel oops.

>> The fix is to also test that the dev pointer returned by
>> pci_get_drvdata is non-NULL.
>> Fixes: befdf89 ("preserve pcd_dev_data after __mlx4_remove_one()")
>> Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
>> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
