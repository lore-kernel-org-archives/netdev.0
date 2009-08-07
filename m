From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: some bug in iproute2
Date: Fri, 7 Aug 2009 10:12:50 +0000
Message-ID: <20090807101250.GA14064@ff.dom.local>
References: <20090806115035.42a22dfc@azure>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jamal <hadi@cyberus.ca>
To: Sergey Popov <popov_sergey@ukr.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f177.google.com ([209.85.211.177]:52391 "EHLO
	mail-yw0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755981AbZHGKM5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Aug 2009 06:12:57 -0400
Received: by ywh7 with SMTP id 7so1995418ywh.21
        for <netdev@vger.kernel.org>; Fri, 07 Aug 2009 03:12:58 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090806115035.42a22dfc@azure>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06-08-2009 10:50, Sergey Popov wrote:
> # tc f add dev eth0 parent 1: proto ip prio 2 u32 match u32 0 0 action ipt -j MARK --set-mark 1
> /usr/lib64/iptables/libipt_mark.so: cannot open shared object file: No such file or directory
> failed to find target MARK
> 
> bad action parsing
> parse_action: bad value (5:ipt)!
> Illegal "action"
> 
> 
> But mark target is compiled in kernel (not a module)
> 
> # iptables -t mangle -A PREROUTING -i eth1 -j MARK --set-mark 1
> # iptables -t mangle -L PREROUTING
> Chain PREROUTING (policy ACCEPT)
> target     prot opt source               destination         
> MARK       all  --  anywhere             anywhere            MARK xset
> 0x1/0xffffffff 
> 
> This shouldn't be.

If you're using iptables > 1.4.2 then it's a known problem.
You can read more in a netdev thread:
Subject: iproute2 action/policer question
starting date: Tue, 09 Jun 2009 22:10:46 +0200

Jarek P.
