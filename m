From: Rick Jones <rick.jones2@hpe.com>
Subject: Re: [RFC PATCH] net: Require socket to allow XPS to set queue mapping
Date: Thu, 25 Aug 2016 13:32:12 -0700
Message-ID: <3fd7a334-c660-6e31-1466-27b08a2c983f@hpe.com>
References: <147215300812.3936.8031402062962283044.stgit@ahduyck-desk.amr.corp.intel.com>
 <1472154564.14381.160.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>,
        Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g2t1383g.austin.hpe.com ([15.233.16.89]:52358 "EHLO
        g2t1383g.austin.hpe.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750703AbcHYUov (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2016 16:44:51 -0400
Received: from g4t3427.houston.hpe.com (g4t3427.houston.hpe.com [15.241.140.73])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by g2t1383g.austin.hpe.com (Postfix) with ESMTPS id 74D6D839C
        for <netdev@vger.kernel.org>; Thu, 25 Aug 2016 20:33:50 +0000 (UTC)
In-Reply-To: <1472154564.14381.160.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/25/2016 12:49 PM, Eric Dumazet wrote:
> On Thu, 2016-08-25 at 12:23 -0700, Alexander Duyck wrote:
>> A simpler approach is provided with this patch.  With it we disable XPS any
>> time a socket is not present for a given flow.  By doing this we can avoid
>> using XPS for any routing or bridging situations in which XPS is likely
>> more of a hinderance than a help.
>
> Yes, but this will destroy isolation for people properly doing VM cpu
> pining.

Why not simply stop enabling XPS by default. Treat it like RPS and RFS 
(unless I've missed a patch...). The people who are already doing the 
extra steps to pin VMs can enable XPS in that case.  It isn't clear that 
one should always pin VMs - for example if a (public) cloud needed to 
oversubscribe the cores.

happy benchmarking,

rick jones
