From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next V2 PATCH 5/5] samples/bpf: add cpumap sample program
 xdp_redirect_cpu
Date: Mon, 2 Oct 2017 14:07:23 +0200
Message-ID: <20171002140723.7667a9b4@redhat.com>
References: <150670281423.23765.8984643281418950330.stgit@firesoul>
        <150670287254.23765.608477053861949304.stgit@firesoul>
        <20170930030607.sk2wzjxxlbhkkt7k@ast-mbp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jakub.kicinski@netronome.com,
        "Michael S. Tsirkin" <mst@redhat.com>,
        Jason Wang <jasowang@redhat.com>, mchan@broadcom.com,
        John Fastabend <john.fastabend@gmail.com>,
        peter.waskiewicz.jr@intel.com,
        Daniel Borkmann <borkmann@iogearbox.net>,
        Andy Gospodarek <andy@greyhouse.net>, brouer@redhat.com
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35600 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751062AbdJBMHh (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 2 Oct 2017 08:07:37 -0400
In-Reply-To: <20170930030607.sk2wzjxxlbhkkt7k@ast-mbp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 29 Sep 2017 20:06:09 -0700
Alexei Starovoitov <alexei.starovoitov@gmail.com> wrote:

> > +/*** Trace point code ***/
> > +
> > +/* Tracepoint format: /sys/kernel/debug/tracing/events/xdp/xdp_redirect/format
> > + * Code in:                kernel/include/trace/events/xdp.h
> > + */
> > +struct xdp_redirect_ctx {
> > +	unsigned short common_type;	//	offset:0;  size:2; signed:0;
> > +	unsigned char common_flags;	//	offset:2;  size:1; signed:0;
> > +	unsigned char common_preempt_count;//	offset:3;  size:1; signed:0;
> > +	int common_pid;			//	offset:4;  size:4; signed:1;  
> 
> this part is not right. First 8 bytes are not accessible by bpf code.
> Please use __u64 pad; or similar here.

I've corrected this in V3.

Can you explain why BPF cannot access these (first 8 bytes) struct members?


> Just noticed that samples/bpf/xdp_monitor_kern.c has the same problem.
> 
> > +
> > +	int prog_id;			//	offset:8;  size:4; signed:1;
> > +	u32 act;			//	offset:12  size:4; signed:0;
> > +	int ifindex;			//	offset:16  size:4; signed:1;
> > +	int err;			//	offset:20  size:4; signed:1;
> > +	int to_ifindex;			//	offset:24  size:4; signed:1;
> > +	u32 map_id;			//	offset:28  size:4; signed:0;
> > +	int map_index;			//	offset:32  size:4; signed:1;
> > +};					//	offset:36  
> 
> the second part of fields is correct.


-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
