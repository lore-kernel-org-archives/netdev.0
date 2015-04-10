From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 3/3 net-next] net_device: Add minimal padding to allow
 for net_device pointer alignment
Date: Fri, 10 Apr 2015 02:03:06 -0700
Message-ID: <1428656586.25985.290.camel@edumazet-glaptop2.roam.corp.google.com>
References: <cover.1428622095.git.tgraf@suug.ch>
	 <1676328eb3e9d02a4432783494d0c5a13f0d4656.1428622095.git.tgraf@suug.ch>
	 <1428626095.25985.282.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150410084816.GB23070@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:37535 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755555AbbDJJDJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Apr 2015 05:03:09 -0400
Received: by igblo3 with SMTP id lo3so12459362igb.0
        for <netdev@vger.kernel.org>; Fri, 10 Apr 2015 02:03:09 -0700 (PDT)
In-Reply-To: <20150410084816.GB23070@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-04-10 at 09:48 +0100, Thomas Graf wrote:

> 
> I assumed kmalloc would guarantee alignment of the return pointer as
> indicated by __alignof__ but I now realize that this can't possibly be the
> case. kmalloc only knows about the size. We'll have to drop patch 3.
> Fortunately it's still below 2K.


If you really care for this, take a look at qdisc_alloc()
and commit d276055c4e90a7278cd5167ba9755c9b214bcff7
("net_sched: reduce fifo qdisc size")

(Note that some setups require ~3 network devices but 3000+ qdisc)

I guess it might be nice to define a common helper and reuse it.
