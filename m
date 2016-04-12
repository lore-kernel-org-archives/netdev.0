From: Julian Anastasov <ja@ssi.bg>
Subject: Re: Issue with ping source address display
Date: Tue, 12 Apr 2016 23:27:55 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1604122315350.1611@ja.home.ssi.bg>
References: <570D35CF.9070006@orlandi.com> <alpine.LFD.2.11.1604122235020.1611@ja.home.ssi.bg> <570D50C8.4010409@orlandi.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Daniele Orlandi <daniele@orlandi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:35749 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S932823AbcDLU17 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Apr 2016 16:27:59 -0400
In-Reply-To: <570D50C8.4010409@orlandi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Tue, 12 Apr 2016, Daniele Orlandi wrote:

> On 12/04/2016 21:38, Julian Anastasov wrote:
> > 
> > 	What is the kernel version?
> 
> Much time passed and I don't remember, however the latest test with IPv6
> ping was made on this host:
> 
> root@monitor:~# uname -a
> Linux monitor 4.4.0-17-generic #33-Ubuntu SMP Tue Mar 29 17:17:28 UTC
> 2016 x86_64 x86_64 x86_64 GNU/Linux

	I asked because I remember for such problem but
at the same time your first report was from Sep 2014, long
before the bad period: 4.0 - 4.1. Can you find and try
this fix from 4.2?:

commit 34b99df4e6256ddafb663c6de0711dceceddfe0e
Author: Julian Anastasov <ja@ssi.bg>
Date:   Tue Jun 23 08:34:39 2015 +0300

    ip: report the original address of ICMP messages
    
    ICMP messages can trigger ICMP and local errors. In this case
    serr->port is 0 and starting from Linux 4.0 we do not return
    the original target address to the error queue readers.
    Add function to define which errors provide addr_offset.
    With this fix my ping command is not silent anymore.

	Because I'm not sure if your kernel includes it.
I also remember that the ping utility can use random memory
when such 4.0/4.1 kernel returns msg_namelen=0:

http://marc.info/?l=linux-netdev&m=143509000420707&w=2

Thread:
http://marc.info/?t=143503781500001&r=1&w=2

Regards
