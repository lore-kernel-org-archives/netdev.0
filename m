From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [net-next PATCH 2/3] pktgen: add sample script
 pktgen_sample05_flow_per_thread.sh
Date: Wed, 13 Jul 2016 15:38:25 -0700
Message-ID: <20160713223823.GA80904@ast-mbp.thefacebook.com>
References: <20160713200525.21875.21960.stgit@firesoul>
 <20160713200609.21875.32584.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, john.fastabend@gmail.com
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:35779 "EHLO
	mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751302AbcGMWia (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jul 2016 18:38:30 -0400
Received: by mail-pa0-f67.google.com with SMTP id dx3so3666479pab.2
        for <netdev@vger.kernel.org>; Wed, 13 Jul 2016 15:38:30 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160713200609.21875.32584.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 13, 2016 at 10:06:10PM +0200, Jesper Dangaard Brouer wrote:
> This pktgen sample script is useful for scalability testing a
> receiver.  The script will simply generate one flow per
> thread (option -t N) using the thread number as part of the
> source IP-address.
> 
> The single flow sample (pktgen_sample03_burst_single_flow.sh)
> have become quite popular, but it is important that developers
> also make sure to benchmark scalability of multiple receive
> queues.
> 
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> ---
>  samples/pktgen/pktgen_sample05_flow_per_thread.sh |   81 +++++++++++++++++++++
>  1 file changed, 81 insertions(+)
...
> +    # Setup source IP-addresses based on thread number
> +    pg_set $dev "src_min 198.18.$((thread+1)).1"
> +    pg_set $dev "src_max 198.18.$((thread+1)).1"

I have similar script that uses udp_src_min/max to change
port number, since port is easier to match on the target host
and we don't use ipv4 ;)
but this script is also good improvement. Thanks!
Acked-by: Alexei Starovoitov <ast@kernel.org>
