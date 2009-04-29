From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: htb parallelism on multi-core platforms
Date: Wed, 29 Apr 2009 15:38:11 +0200
Message-ID: <20090429133810.GB2759@ami.dom.local>
References: <1240495002.6554.155.camel@blade.ines.ro> <20090423181936.GA2756@ami.dom.local> <Pine.LNX.4.64.0904232148120.13815@ask.diku.dk> <1240566136.6554.220.camel@blade.ines.ro> <Pine.LNX.4.64.0904281142270.21301@tyr.diku.dk> <1241000494.6554.307.camel@blade.ines.ro> <Pine.LNX.4.64.0904291225010.23626@tyr.diku.dk> <1241003006.6554.322.camel@blade.ines.ro> <20090429122312.GA2759@ami.dom.local> <1241010951.6554.355.camel@blade.ines.ro>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jesper Dangaard Brouer <hawk@diku.dk>,
	Denys Fedoryschenko <denys@visp.net.lb>,
	netdev <netdev@vger.kernel.org>,
	Calin Velea <calin.velea@gemenii.ro>
To: Radu Rendec <radu.rendec@ines.ro>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f163.google.com ([209.85.218.163]:58017 "EHLO
	mail-bw0-f163.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751757AbZD2NjD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2009 09:39:03 -0400
Received: by bwz7 with SMTP id 7so1173011bwz.37
        for <netdev@vger.kernel.org>; Wed, 29 Apr 2009 06:39:01 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1241010951.6554.355.camel@blade.ines.ro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 29, 2009 at 04:15:51PM +0300, Radu Rendec wrote:
...
> I've just had a look at Calin's approach to optimizing u32 lookups. It
> does indeed make a very nice use of u32 hash capabilities, resulting in
> a maximum of 4 lookups. The algorithm he uses takes advantage of the
> fact that only a (small) subset of the whole ipv4 address space is
> actually used in an ISP's network.
...

Anyway, it looks like your main problem, and I doubt even dividing
current work by e.g. 4 cores (if it were multi-threaded) is enough.
These lookups are simply too long.

> > Btw. #2: I think you wrote you didn't use iptables...
> No, I don't use iptables.

But your oprofile shows them. Maybe you shouldn't compile it into
kernel at all?

> 
> Btw, the e1000e driver seems to have no way to disable NAPI. Am I
> missing something (like a global kernel config option that disables NAPI
> completely)?

Calin uses older kernel, and maybe e1000 driver, I don't know.

Jarek P.
