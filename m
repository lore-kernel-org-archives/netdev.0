From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: "xfrm: Fix the gc threshold value for ipv4" broke my IPSec
 connections
Date: Tue, 15 Oct 2013 15:51:26 -0700
Message-ID: <1381877486.2045.78.camel@edumazet-glaptop.roam.corp.google.com>
References: <525DA855.1010905@daper.net>
	 <1381870957.2045.73.camel@edumazet-glaptop.roam.corp.google.com>
	 <525DBE65.1070707@daper.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Damian Pietras <damianp@daper.net>,
	Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:51856 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933565Ab3JOWv1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Oct 2013 18:51:27 -0400
Received: by mail-pa0-f45.google.com with SMTP id rd3so95556pab.32
        for <netdev@vger.kernel.org>; Tue, 15 Oct 2013 15:51:27 -0700 (PDT)
In-Reply-To: <525DBE65.1070707@daper.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-10-16 at 00:15 +0200, Damian Pietras wrote:
> On 15.10.2013 23:02, Eric Dumazet wrote:
> >> 703fb94ec58e0e8769380c2877a8a34aeb5b6c97
> >> xfrm: Fix the gc threshold value for ipv4
> >>
> >> Reverting it on 3.10.15 fixes my issue. This seems to be there from 3.7
> >> and I don't really believe such simple case stayed broken for so long.
> >> Em I missing something or there is really a bug?
> >>
> >> If smeone is interested in details of this configuration and commands
> >> I'm running, just let me know. This was reproduced with few VMs under XEN.
> >>
> > 
> > It looks like you need to tune /proc/sys/net/ipv4/xfrm4_gc_thresh to a
> > sensible value given your workload.
> > 
> > try :
> > 
> > echo 65536 >/proc/sys/net/ipv4/xfrm4_gc_thresh
> > 
> > Presumably the 1024 default is really too small...
> 
> Now it's working in my test setup, I'm changing it on the production
> boxes, thanks!
> 
> 

Steffen, what do you think ?

1024 seems really small, given we had much higher values.

(256 K on a 1GB host)

This sysctl also needs an entry in
Documentation/networking/ip-sysctl.txt
