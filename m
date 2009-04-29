From: Radu Rendec <radu.rendec@ines.ro>
Subject: Re: htb parallelism on multi-core platforms
Date: Wed, 29 Apr 2009 19:21:11 +0300
Message-ID: <1241022071.6554.375.camel@blade.ines.ro>
References: <1240495002.6554.155.camel@blade.ines.ro>
	 <20090423181936.GA2756@ami.dom.local>
	 <Pine.LNX.4.64.0904232148120.13815@ask.diku.dk>
	 <1240566136.6554.220.camel@blade.ines.ro>
	 <Pine.LNX.4.64.0904281142270.21301@tyr.diku.dk>
	 <1241000494.6554.307.camel@blade.ines.ro>
	 <Pine.LNX.4.64.0904291225010.23626@tyr.diku.dk>
	 <1241003006.6554.322.camel@blade.ines.ro>
	 <20090429122312.GA2759@ami.dom.local>
	 <1241010951.6554.355.camel@blade.ines.ro>
	 <20090429133810.GB2759@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <hawk@diku.dk>,
	Denys Fedoryschenko <denys@visp.net.lb>,
	netdev <netdev@vger.kernel.org>,
	Calin Velea <calin.velea@gemenii.ro>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from NAT-172-Unkn.Local.iNES.RO ([80.86.100.172]:46886 "EHLO
	blade.ines.ro" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753142AbZD2QVq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2009 12:21:46 -0400
In-Reply-To: <20090429133810.GB2759@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I finally managed to disable NAPI on e1000e - apparently it can only be
done on the "official" Intel driver (downloaded from their website), by
compiling with "make CFLAGS_EXTRA=-DE1000E_NO_NAPI". This doesn't seem
to be available in the (2.6.29) kernel driver.

With NAPI disabled, 4 (of 8) cores go to 100% (instead of only one), but
overall throughput *decreases* from ~110K pps (with NAPI) to ~80K pps.
This makes sense, since h/w interrupt is much more time consuming than
polling (that's the whole idea behind NAPI anyway).

Radu Rendec


