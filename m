From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net v2] gso: Update tunnel segmentation to support Tx
 checksum offload
Date: Wed, 10 Jul 2013 17:42:14 -0700
Message-ID: <1373503334.4600.27.camel@edumazet-glaptop>
References: <20130711000015.13134.17801.stgit@ahduyck-hc1.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
	pshelar@nicira.com, joseph.gasparakis@intel.com, jesse@nicira.com
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:35615 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751434Ab3GKAmQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jul 2013 20:42:16 -0400
Received: by mail-ob0-f174.google.com with SMTP id wd20so9305003obb.33
        for <netdev@vger.kernel.org>; Wed, 10 Jul 2013 17:42:16 -0700 (PDT)
In-Reply-To: <20130711000015.13134.17801.stgit@ahduyck-hc1.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-07-10 at 17:05 -0700, Alexander Duyck wrote:
> This change makes it so that the GRE and VXLAN tunnels can make use of Tx
> checksum offload support provided by some drivers via the hw_enc_features.
> Without this fix enabling GSO means sacrificing Tx checksum offload and
> this actually leads to a performance regression as shown below:
> 
>             Utilization
>             Send
> Throughput  local         GSO
> 10^6bits/s  % S           state
>   6276.51   8.39          enabled
>   7123.52   8.42          disabled

While testing your patch, I discovered TSO support is completely broken
on GRE, using bnx2x testbed.

Oh well.

It seems Nicira guys do not test a lot their patches.
