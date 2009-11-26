From: Jesper Dangaard Brouer <jdb@comx.dk>
Subject: Re: Strange CPU load when flushing route cache (kernel 2.6.31.6)
Date: Thu, 26 Nov 2009 11:51:56 +0100
Message-ID: <1259232716.30983.101.camel@jdb-workstation>
References: <1258970332.29747.262.camel@jdb-workstation>
	 <4B0A63FA.5000804@gmail.com> <1258979320.29747.270.camel@jdb-workstation>
	 <4B0A8D41.6010608@gmail.com>
	 <Pine.LNX.4.64.0911231437020.24347@ask.diku.dk>
	 <4B0A9631.2030705@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: Jesper Dangaard Brouer <hawk@diku.dk>,
	Linux Kernel Network Hackers <netdev@vger.kernel.org>,
	Robert Olsson <robert@herjulf.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:54211 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760322AbZKZKuU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Nov 2009 05:50:20 -0500
In-Reply-To: <4B0A9631.2030705@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2009-11-23 at 15:03 +0100, Eric Dumazet wrote:
> > grep LowTotal /proc/meminfo
> > LowTotal:         747080 kB
> > 
> > What does that mean?  Is it bad? What should I run on a 32-bit
> > system/kernel?
> 
> If you have more than 1GB of physical ram, and use your machine as a router, you might
> compile a 2GB/2GB User/Kernel kernel, to get twice available RAM for kernel
> and more IP route entries (if needed)

Can I still use this option if the machine "only" have 2G of physical
RAM?  Most of my production machines have 2G RAM.

Just to verify: This is not an issue on 64-bit kernels right?

> make menuconfig
> --> Processor type and features
>   --> Memory split
>     --> 2G/2G

For completeness sake, Memory split depends on "if EMBEDDED"

So I also needed to enable:

 make menuconfig
  --> General setup
     --> Configure standard kernel features (for small systems) 


> > Can you recommend any other /proc/sys/ tuning options?
> 
> Really hard to say without exact context of use :)

The machines does Internet traffic routing, but with a VERY large
iptables rulesets, e.g. on one production machine I have 18409 chains
and 62916 iptables rules. (I did most of the scalability patches to
iptables userspace to make this work...). And the machines also uses a
very large HTB tree.  Basically I do, per customer, Access Control,
Bandwidth limiting and Personal firewall.

Also note that I'm reserving extra vmalloc memory as iptables uses
vmalloc'ed memory...

> > Does my kernel boot option rhash_entries=262143 make sense anymore?
> > Or do we adjust the hash bucket size dynamically these days?
> > 
> 
> Its not dynamic yet.

Okay I'll keep boot parameter then... or is it possible to resize the
hash runtime?


-- 
Med venlig hilsen / Best regards
  Jesper Brouer
  ComX Networks A/S
  Linux Network Kernel Developer
  Cand. Scient Datalog / MSc.CS
  Author of http://adsl-optimizer.dk
  LinkedIn: http://www.linkedin.com/in/brouer
