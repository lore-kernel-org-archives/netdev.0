From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH] net: Require socket to allow XPS to set queue
 mapping
Date: Thu, 25 Aug 2016 14:08:17 -0700
Message-ID: <1472159297.14381.162.camel@edumazet-glaptop3.roam.corp.google.com>
References: <147215300812.3936.8031402062962283044.stgit@ahduyck-desk.amr.corp.intel.com>
         <1472154564.14381.160.camel@edumazet-glaptop3.roam.corp.google.com>
         <3fd7a334-c660-6e31-1466-27b08a2c983f@hpe.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
        netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hpe.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:33153 "EHLO
        mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756158AbcHYVN5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2016 17:13:57 -0400
Received: by mail-pa0-f53.google.com with SMTP id ti13so20205903pac.0
        for <netdev@vger.kernel.org>; Thu, 25 Aug 2016 14:13:48 -0700 (PDT)
In-Reply-To: <3fd7a334-c660-6e31-1466-27b08a2c983f@hpe.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-08-25 at 13:32 -0700, Rick Jones wrote:
> On 08/25/2016 12:49 PM, Eric Dumazet wrote:
> > On Thu, 2016-08-25 at 12:23 -0700, Alexander Duyck wrote:
> >> A simpler approach is provided with this patch.  With it we disable XPS any
> >> time a socket is not present for a given flow.  By doing this we can avoid
> >> using XPS for any routing or bridging situations in which XPS is likely
> >> more of a hinderance than a help.
> >
> > Yes, but this will destroy isolation for people properly doing VM cpu
> > pining.
> 
> Why not simply stop enabling XPS by default. Treat it like RPS and RFS 
> (unless I've missed a patch...). The people who are already doing the 
> extra steps to pin VMs can enable XPS in that case.  It isn't clear that 
> one should always pin VMs - for example if a (public) cloud needed to 
> oversubscribe the cores.
> 

When XPS was submitted, it was _not_ enabled by default and 'magic'

Some NIC vendors decided it was a good thing, you should complain to
them ;)
