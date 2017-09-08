From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH net] bpf: don't select potentially stale ri->map from
 buggy xdp progs
Date: Fri, 8 Sep 2017 07:06:10 +0200
Message-ID: <20170908070610.4b8e1df1@redhat.com>
References: <01d69254802986ad3a8b18a8650c45df3df95def.1504821825.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, ast@fb.com, john.fastabend@gmail.com,
        andy@greyhouse.net, netdev@vger.kernel.org, brouer@redhat.com
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45944 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751088AbdIHFGR (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 8 Sep 2017 01:06:17 -0400
In-Reply-To: <01d69254802986ad3a8b18a8650c45df3df95def.1504821825.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri,  8 Sep 2017 00:14:51 +0200
Daniel Borkmann <daniel@iogearbox.net> wrote:

> +	/* This is really only caused by a deliberately crappy
> +	 * BPF program, normally we would never hit that case,
> +	 * so no need to inform someone via tracepoints either,
> +	 * just bail out.
> +	 */
> +	if (unlikely(map_owner != xdp_prog))
> +		return -EINVAL;

IMHO we do need to call the tracepoint here.  It is not just crappy
BPF-progs that cause this situation, it is also drivers not implementing
XDP_REDIRECT yet (which is all but ixgbe).  Due to the level XDP
operates at, tracepoints are the only way users can runtime troubleshoot
their XDP programs.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
