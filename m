From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH] net: Require socket to allow XPS to set queue
 mapping
Date: Thu, 25 Aug 2016 12:49:24 -0700
Message-ID: <1472154564.14381.160.camel@edumazet-glaptop3.roam.corp.google.com>
References: <147215300812.3936.8031402062962283044.stgit@ahduyck-desk.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rick.jones2@hpe.com
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:32952 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753343AbcHYT4o (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2016 15:56:44 -0400
Received: by mail-pf0-f169.google.com with SMTP id y134so20680023pfg.0
        for <netdev@vger.kernel.org>; Thu, 25 Aug 2016 12:56:27 -0700 (PDT)
In-Reply-To: <147215300812.3936.8031402062962283044.stgit@ahduyck-desk.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-08-25 at 12:23 -0700, Alexander Duyck wrote:
> I have been seeing a number of issues where XPS leads to issues with
> packets being reordered in the transmit queues of the device drivers.  The
> main situation where this seems to occur is when a VM us using a tap
> interface to send packets to the network via a NIC that has XPS enabled.
> 
> A bit of looking into this revealed the main issue is that the scheduler
> seems to be migrating the VM between CPUs and as this occurs the traffic
> for a given flow from a VM is following this migration and hopping between
> Tx queues leading to packet reordering.
> 
> A workaround for this is to make certain all the VMs have RPS enabled on
> the tap interfaces, however this requires extra configuration on the host
> for each VM created.
> 
> A simpler approach is provided with this patch.  With it we disable XPS any
> time a socket is not present for a given flow.  By doing this we can avoid
> using XPS for any routing or bridging situations in which XPS is likely
> more of a hinderance than a help.

Yes, but this will destroy isolation for people properly doing VM cpu
pining.

With this patch, DDOS traffic coming from a VM will hit all TX queues.
