From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [RFC 1/2] net/ethtool: Add new coalescing parameter for queue
Date: Tue, 08 Dec 2015 10:15:53 -0800
Message-ID: <56671E59.40402@gmail.com>
References: <1449549750-12448-1-git-send-email-kan.liang@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: jesse.brandeburg@intel.com, andi@firstfloor.org,
	alexander.duyck@gmail.com, jeffrey.t.kirsher@intel.com,
	shannon.nelson@intel.com, carolyn.wyborny@intel.com,
	donald.c.skidmore@intel.com, mitch.a.williams@intel.com,
	ogerlitz@mellanox.com, edumazet@google.com, jiri@mellanox.com,
	sfeldma@gmail.com, gospo@cumulusnetworks.com,
	sasha.levin@oracle.com, dsahern@gmail.com, tj@kernel.org,
	cascardo@redhat.com, corbet@lwn.net
To: kan.liang@intel.com, netdev@vger.kernel.org, davem@davemloft.net,
	bwh@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:33838 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751703AbbLHSQD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2015 13:16:03 -0500
Received: by pacwq6 with SMTP id wq6so15602292pac.1
        for <netdev@vger.kernel.org>; Tue, 08 Dec 2015 10:16:02 -0800 (PST)
In-Reply-To: <1449549750-12448-1-git-send-email-kan.liang@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/12/15 20:42, kan.liang@intel.com wrote:
> From: Kan Liang <kan.liang@intel.com>
> 
> Intrdouce "queue" option for coalesce getting and setting.
> For coalesce getting, only the coalescing parameters from specific
> queue will be passed to user space.
> For coalesce setting, the coalescing parameters will only be applied to
> specific queue.
> If the queue is set to -1, the coalescing parameters will apply to all
> queues.

This looks like a good start, but there are a few things that need to be
clarified, in particular:

- if the number of TX and RX queues differ, but the ethtool coalesce
structure contains parameters that affect both the RX and TX side, and
the queue number is invalid/non-existent for one of these sides, what is
the expected outcome? Same question with specifying a queue number, with
RX queue N not belonging to the same queue pair as TX queue N?

- from an user perspective do we want to iterate over all queues to set
their parameters, or should we have a queue bitmask parameter which
allows setting them with the same settings in one shot? What would be
the appropriate bitmask size then (32-bits with 16-bits for TX and
16-bits for RX might be too small)?

Thanks
-- 
Florian
