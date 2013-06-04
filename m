From: Jesper Dangaard Brouer <jbrouer@redhat.com>
Subject: Re: [PATCH iproute2] htb: report overhead attribute
Date: Tue, 4 Jun 2013 13:11:47 +0200
Message-ID: <20130604131147.2d357322@redhat.com>
References: <20130529151330.22c5c89e@redhat.com>
	<1370207755.24311.81.camel@edumazet-glaptop>
	<1370208781.24311.89.camel@edumazet-glaptop>
	<51ACB9FE.1020100@hp.com>
	<1370274962.24311.156.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Rick Jones <rick.jones2@hp.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	netdev <netdev@vger.kernel.org>,
	"russell-tcatm@stuart.id.au" <russell-tcatm@stuart.id.au>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47209 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753130Ab3FDLMN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Jun 2013 07:12:13 -0400
In-Reply-To: <1370274962.24311.156.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 03 Jun 2013 08:56:02 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Mon, 2013-06-03 at 08:45 -0700, Rick Jones wrote:
> 
> > Is it (still) possible to have a negative overhead?
> > 
> > http://www.linksysinfo.org/index.php?threads/speedmod-with-tc-atm-qos-patch-for-adsl.31541/
> 
> overhead always has been unsigned in the kernel.
> 
> What you describe is a userland hack in tc command.
> (or a bug)

Rick is referencing Russell Stuart's patches, where a negative overhead
was possible.
 http://ace-host.stuart.id.au/russell/files/tc/tc-atm/#history

But my patches got accepted into the kernel, where a negative
overhead was not possible. In retrospect, we should have supported a
negative overhead.

A negative overhead *is* a valid use-case, and we should work towards
supporting this. E.g. by changing the recent added "u16 overhead" in
struct psched_ratecfg to be "s16" (ref [1]) ?


[1] commit 01cb71d2d47 (net_sched: restore "overhead xxx" handling)
 https://git.kernel.org/cgit/linux/kernel/git/davem/net.git/commit/?id=01cb71d2d47b78354358e4bb938bb06323e17498

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
