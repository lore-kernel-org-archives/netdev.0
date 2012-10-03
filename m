From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: RED tc qdisc not dropping?
Date: Wed, 03 Oct 2012 23:12:46 +0200
Message-ID: <1349298766.10199.5.camel@edumazet-glaptop>
References: <986427880.11879793.1349295290592.JavaMail.root@cds046>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ken Savage <kens1835@shaw.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:48272 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755369Ab2JCVMv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Oct 2012 17:12:51 -0400
Received: by bkcjk13 with SMTP id jk13so6397673bkc.19
        for <netdev@vger.kernel.org>; Wed, 03 Oct 2012 14:12:50 -0700 (PDT)
In-Reply-To: <986427880.11879793.1349295290592.JavaMail.root@cds046>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-10-03 at 14:14 -0600, Ken Savage wrote:
> Hi there,
> 
> I'm running openSUSE 12.2, using the machine as a router/WANsim device.
> 
> Previously, I was running an older CentOS installation with a 2.6 kernel,
> and my tc-red commands ran just fine, and imposed some bandwidth constraint
> to the packets upon egress.  In 3.4.6, this doesn't seem to be the case
> any longer.
> 
> Without any restrictions, there would be 25-30Mbps of traffic flowing out
> the interface -- this is to give you a sense of the data rate.
> 
> 
> Now, this said, I did notice that the latest RED code has the 'harddrop'
> option that I didn't have under CentOS with kernel 2.6.  So in my attempt
> to see ANYTHING happening with 3.4.6, I entered:
> 
> tc qdisc add dev eth0 root red limit 40000 min 3000 max 9000 avpkt 1000 burst 5 harddrop probability 1
> 
> 
> Issuing 'tc -s -d qdisc show dev eth0', I obtain:
> 
> qdisc red 8006: root refcnt 2 limit 40000b min 3000b max 9000b harddrop ewma 2 probability 0.73242 Scell_log 12
>  Sent 254028472 bytes 207494 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
>   marked 0 early 0 pdrop 0 other 0
> 
> 
> All those zeroes seem a little amiss to me  ;)
> 

Not sure I understand...

Why RED should drop a packet if there is no backlog ?

if you NIC has Gigabit speed, RED will allow Gigabit speed as well.
