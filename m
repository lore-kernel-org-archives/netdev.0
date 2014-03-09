From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [BUG?] ixgbe: only num_online_cpus() of the tx queues are
 enabled
Date: Sun, 09 Mar 2014 12:37:12 -0700
Message-ID: <1394393832.20149.114.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAG+wggZOQ_VyAiLBuUUfW13=OqUun3g1vnYj5SEuWN+3hHreLg@mail.gmail.com>
	 <1394292461.20149.55.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAG+wggaUHeD5Vm_HF9m4+1SZZOUo_GeQroM+0kyA_qTC5c8=3Q@mail.gmail.com>
	 <1394335754.20149.73.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAG+wggY=5BWaDujaiP6hnD5vTsXiOBNqBDYnqjEW_F4fdaMOyw@mail.gmail.com>
	 <1394372662.20149.92.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAG+wgga4fYOS=V6YHVNpYiu5RgqSEJ5qbM4XaPFdTUnYmhHaog@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.r.fastabend@intel.com>,
	netdev@vger.kernel.org, Erez Zadok <ezk@fsl.cs.sunysb.edu>,
	Dean Hildebrand <dhildeb@us.ibm.com>,
	Geoff Kuenning <geoff@cs.hmc.edu>
To: Ming Chen <v.mingchen@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f48.google.com ([209.85.160.48]:61158 "EHLO
	mail-pb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751327AbaCIThO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Mar 2014 15:37:14 -0400
Received: by mail-pb0-f48.google.com with SMTP id md12so6322814pbc.21
        for <netdev@vger.kernel.org>; Sun, 09 Mar 2014 12:37:14 -0700 (PDT)
In-Reply-To: <CAG+wgga4fYOS=V6YHVNpYiu5RgqSEJ5qbM4XaPFdTUnYmhHaog@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2014-03-09 at 15:22 -0400, Ming Chen wrote:
> Hi Eric and John,
> 
> I could not get the command working:
> 
> #ethtool -l p3p1
> Channel parameters for p3p1:
> Pre-set maximums:
> RX:             0
> TX:             0
> Other:          1
> Combined:       63
> Current hardware settings:
> RX:             0
> TX:             0
> Other:          1
> Combined:       6
> 
> #ethtool -L p3p1 rx 1 tx 1
> Cannot set device channel parameters: Invalid argument
> 
> #ethtool -L p3p1 rx 1 tx 1 other 1
> other unmodified, ignoring
> Cannot set device channel parameters: Invalid argument

You need more recent kernel for ixgbe support :

commit 4c696ca9fbabc5f94a3c6db7f009e73f0ef21831
Author: Alexander Duyck <alexander.h.duyck@intel.com>
Date:   Thu Jan 17 08:39:33 2013 +0000

    ixgbe: Add support for set_channels ethtool operation
    
    This change adds support for the ethtool set_channels operation.
    
    Since the ixgbe driver has to support DCB as well as the other modes the
    assumption I made here is that the number of channels in DCB modes refers
    to the number of queues per traffic class, not the number of queues total.
    
    CC: Ben Hutchings <bhutchings@solarflare.com>
    Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
    Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
    Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
