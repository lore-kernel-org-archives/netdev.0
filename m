From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next] net: bridge: add per-port group_fwd_mask with
 less restrictions
Date: Sat, 30 Sep 2017 00:01:24 +0300
Message-ID: <e9a70870-9b6b-0ec4-de1e-d41da80fd10f@cumulusnetworks.com>
References: <1506517964-17479-1-git-send-email-nikolay@cumulusnetworks.com>
 <20170929081420.3b069170@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
        bridge@lists.linux-foundation.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:53512 "EHLO
        mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752003AbdI2VB1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 29 Sep 2017 17:01:27 -0400
Received: by mail-wm0-f49.google.com with SMTP id q132so1599348wmd.2
        for <netdev@vger.kernel.org>; Fri, 29 Sep 2017 14:01:27 -0700 (PDT)
In-Reply-To: <20170929081420.3b069170@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 29/09/17 18:14, Stephen Hemminger wrote:
> On Wed, 27 Sep 2017 16:12:44 +0300
> Nikolay Aleksandrov <nikolay@cumulusnetworks.com> wrote:
> 
>> We need to be able to transparently forward most link-local frames via
>> tunnels (e.g. vxlan, qinq). Currently the bridge's group_fwd_mask has a
>> mask which restricts the forwarding of STP and LACP, but we need to be able
>> to forward these over tunnels and control that forwarding on a per-port
>> basis thus add a new per-port group_fwd_mask option which only disallows
>> mac pause frames to be forwarded (they're always dropped anyway).
>> The patch does not change the current default situation - all of the others
>> are still restricted unless configured for forwarding.
>> We have successfully tested this patch with LACP and STP forwarding over
>> VxLAN and qinq tunnels.
>>
>> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> 
> LACP is fine, but STP must not be forwarded if STP in user or kernel
> mode is enabled.
> 
> Please update this patch or revert it.
> 

The default has not changed, STP is still _not_ forwarded. It can be only if explicitly
requested by the user and that means the port might be participating in STP but not
the bridge's STP, that is explicitly forward all STP frames from that port.
I don't think we have to change anything.
