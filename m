From: Sathya Perla <sathya.perla@broadcom.com>
Subject: RE: [net-next PATCH 0/4] be2net: patch set
Date: Wed, 3 Aug 2016 12:51:16 +0530
Message-ID: <f24010615e954077177f1042e4406642@mail.gmail.com>
References: <1469611578-29665-1-git-send-email-sathya.perla@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f175.google.com ([209.85.161.175]:33885 "EHLO
	mail-yw0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752300AbcHCHVS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Aug 2016 03:21:18 -0400
Received: by mail-yw0-f175.google.com with SMTP id z8so220188651ywa.1
        for <netdev@vger.kernel.org>; Wed, 03 Aug 2016 00:21:18 -0700 (PDT)
In-Reply-To: <1469611578-29665-1-git-send-email-sathya.perla@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
On Behalf Of Sathya Perla
> Sent: Wednesday, July 27, 2016 2:56 PM
> To: netdev@vger.kernel.org
> Subject: [net-next PATCH 0/4] be2net: patch set
>
> Hi David, pls consider applying this patch-set to the net-next tree.
>
> Patch 1 fixes the driver to workaournd a bug in the Lancer FW in the
vlan-config cmd processing. The FW in some
> cases clears the vlan-promisc setting even if it cannot apply the vlan
filter. The driver has no means of knowing if
> the vlan-promisc setting has been cleared or not. This patch now
explicitly clears the vlan-promisc setting via the
> RX-Filter cmd and then tries to program the vlan-list.
>
> Patch 2 fixes the failure path in the vlan vid add code.
> The driver currently removes a new vid from the adapter->vids[] array if
> be_vid_config() returns an error, which occurs when there is an error in
HW/FW. This is wrong. After the HW/FW
> error is recovered from, we need the complete vids[] array to re-program
the vlan list.
>
> Patch 3 fixes the ndo_set_rx_mode() path to avoid unnecessary multicast
list updates to the FW. Each time the
> ndo_set_rx_mode() routine is called, the driver programs the multicast
list in the adapter without checking if
> there are any changes to the list. This leads to a flood of RX_FILTER
cmds when a number of vlan interfaces are
> configured over the device, as the ndo_ gets called for each vlan
interface. To avoid this, we now use
> __dev_mc_sync() and __dev_uc_sync() API, but only to detect if there is
a change in the mc/uc lists. Now that we
> use this API, the code has to be-designed to issue these API calls for
each invocation of the ndo_ call.
>
> Patch 4 replaces polling with sleeping in the FW completion path.
> The ndo_set_rx_mode() and ndo_add/del_vxlan_port() calls may be called
with BHs disabled. The driver currently
> issues the required cmds to the FW in these contexts and polls on
completions from the FW, while BHs remain
> disabled.  This can cause either packet loss or packet reception to be
delayed on that CPU.  This patch defers
> processing of the above cmds to a separate workqueue. With this change,
FW cmds are now issued only in
> process context. Now that the FW cmds are issued only in process
context, they can sleep waiting for a
> completion instead of polling.

David, do you want me to re-submit this patch-set after net-next re-opens
or would you consider applying this now itself?

thanks,
-Sathya
