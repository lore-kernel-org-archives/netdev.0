From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH v6 01/12] bpf: add XDP prog type for early driver filter
Date: Mon, 11 Jul 2016 14:58:45 +0200
Message-ID: <20160711145845.215e2c23@redhat.com>
References: <1467944124-14891-1-git-send-email-bblanco@plumgrid.com>
	<1467944124-14891-2-git-send-email-bblanco@plumgrid.com>
	<20160709101403.1ed7d021@redhat.com>
	<CALx6S36dnA_vXBJVpLTZc6WyZaDh_hnw4vpp57EC2jsfA0vHcQ@mail.gmail.com>
	<20160710153731.62d6773d@redhat.com>
	<20160710170922.GC6657@gmail.com>
	<CALx6S34623bJP=L2EVNV6Gfx4oF=io5TGsGXCDQ=WH3VnHweMg@mail.gmail.com>
	<578371CE.6090305@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom@herbertland.com>,
	Brenden Blanco <bblanco@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Martin KaFai Lau <kafai@fb.com>, Ari Saha <as754m@att.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Or Gerlitz <gerlitz.or@gmail.com>,
	john fastabend <john.fastabend@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Thomas Graf <tgraf@suug.ch>, brouer@redhat.com
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42467 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751565AbcGKM6x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jul 2016 08:58:53 -0400
In-Reply-To: <578371CE.6090305@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Trying to sum up the main points of the discussion.

Two main issues:

1) Allowing to load an XDP/eBPF program what use return codes not
   compatible with the drivers.

2) Default dropping at this level make is hard to debug / no-metrics.

To solve issue #1, I proposed defining a fallback semantics.  I guess,
people didn't like that semantics.
 The only other solution I see, is to NOT-allow programs to be loaded
if they want to use return-codes/features not supported by the driver,
e.g reject XDP programs.

Given we cannot automatic deduct used return codes (if prog is table
driven) then we need some kind of versioning or feature codes.  Could
this be modeled after NIC "features"?

I guess this could also help HW offload engines, if eBPF programs
register/annotate their needed capabilities upfront?


For issue #2 (default drop): If the solution for issue #1 is to only
loaded compatible programs, then I agree that unknown return code
should default to drop.

For debug-ability, it should be easy to extend the call
bpf_warn_invalid_xdp_action() to log more information for debugging
purposes.  Which for performance/DoS reasons should be off by default.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
