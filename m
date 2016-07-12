From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH v8 01/11] bpf: add XDP prog type for early driver filter
Date: Tue, 12 Jul 2016 15:14:31 +0200
Message-ID: <20160712151431.26cbac82@redhat.com>
References: <1468309894-26258-1-git-send-email-bblanco@plumgrid.com>
	<1468309894-26258-2-git-send-email-bblanco@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Saeed Mahameed <saeedm@dev.mellanox.co.il>,
	Martin KaFai Lau <kafai@fb.com>, Ari Saha <as754m@att.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Or Gerlitz <gerlitz.or@gmail.com>, john.fastabend@gmail.com,
	hannes@stressinduktion.org, Thomas Graf <tgraf@suug.ch>,
	Tom Herbert <tom@herbertland.com>,
	Daniel Borkmann <daniel@iogearbox.net>, brouer@redhat.com
To: Brenden Blanco <bblanco@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33021 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751014AbcGLNOp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jul 2016 09:14:45 -0400
In-Reply-To: <1468309894-26258-2-git-send-email-bblanco@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tue, 12 Jul 2016 00:51:24 -0700 Brenden Blanco <bblanco@plumgrid.com> wrote:

> Add a new bpf prog type that is intended to run in early stages of the
> packet rx path. Only minimal packet metadata will be available, hence a
> new context type, struct xdp_md, is exposed to userspace. So far only
> expose the packet start and end pointers, and only in read mode.
> 
> An XDP program must return one of the well known enum values, all other
> return codes are reserved for future use. Unfortunately, this
> restriction is hard to enforce at verification time, so take the
> approach of warning at runtime when such programs are encountered. Out
> of bounds return codes should alias to XDP_ABORTED.

This is going to be a serious usability problem, when XDP gets extended
with newer features.

How can users know what XDP capabilities a given driver support?

If the user loads a XDP program using capabilities not avail in the
driver, then all his traffic will be hard dropped.


My proposal is to NOT allow XDP programs to be loaded if they want to use
return-codes/features not supported by the driver.  Thus, eBPF programs
register/annotate their needed capabilities upfront (I guess this could
also help HW offload engines).

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
