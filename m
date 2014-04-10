From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Does IPv6 support Jumbograms ?
Date: Wed, 09 Apr 2014 17:36:10 -0700
Message-ID: <1397090170.16584.21.camel@edumazet-glaptop2.roam.corp.google.com>
References: <5345A2B3.7040602@gmail.com>
	 <1397079665.16584.17.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140409223546.GH27255@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Francois WELLENREITER <f.wellenreiter@gmail.com>,
	netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:39209 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932847AbaDJAgM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Apr 2014 20:36:12 -0400
Received: by mail-pd0-f180.google.com with SMTP id v10so3106547pde.25
        for <netdev@vger.kernel.org>; Wed, 09 Apr 2014 17:36:11 -0700 (PDT)
In-Reply-To: <20140409223546.GH27255@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-04-10 at 00:35 +0200, Hannes Frederic Sowa wrote:
> On Wed, Apr 09, 2014 at 02:41:05PM -0700, Eric Dumazet wrote:
> > What do you mean by blocked ?
> > 
> > Please give more details (kernel version, exact mtu...), because it
> > should not happen !
> > 
> > # ifconfig lo mtu 100000
> > # scp -6 vmlinux edumazet@ip6-localhost:/tmp
> > Password: 
> > vmlinux
> > 100%   24MB  23.5MB/s   00:00    
> > # ls -l /tmp/vmlinux
> > -rwxr-xr-x 1 edumazet eng 24668915 Apr  9 14:37 /tmp/vmlinux
> 
> I couldn't test it on my development system with a recent net-next kernel
> yet, but on my laptop with a distribution 3.13.9 kernel this happened too.

Oh well, it seems ip6_mtu() needs to cap mtu to max mtu for non
jumbograms...

-	return mtu;
+	return min_t(unsigned int, mtu, IP6_MAX_MTU);

#define IP6_MAX_MTU (65535 + 40)
