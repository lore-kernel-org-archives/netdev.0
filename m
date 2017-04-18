From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH v4 net-next RFC] net: Generic XDP
Date: Tue, 18 Apr 2017 22:26:16 +0200
Message-ID: <20170418222616.4761a781@redhat.com>
References: <20170413.120925.2082322246776478766.davem@davemloft.net>
        <CACKFLikm1vDzz8eQJMJOEsbv-NNV41ki2TEPVPCSpP6VjaowBA@mail.gmail.com>
        <20170413.162315.1889531431093534154.davem@davemloft.net>
        <20170415005949.GB73685@ast-mbp.thefacebook.com>
        <20170418190535.GG4730@C02RW35GFVH8.dhcp.broadcom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        David Miller <davem@davemloft.net>, michael.chan@broadcom.com,
        netdev@vger.kernel.org, xdp-newbies@vger.kernel.org,
        brouer@redhat.com
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57948 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755109AbdDRU00 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 18 Apr 2017 16:26:26 -0400
In-Reply-To: <20170418190535.GG4730@C02RW35GFVH8.dhcp.broadcom.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tue, 18 Apr 2017 15:05:35 -0400 Andy Gospodarek <andy@greyhouse.net> wrote:

> On Fri, Apr 14, 2017 at 05:59:51PM -0700, Alexei Starovoitov wrote:
> > On Thu, Apr 13, 2017 at 04:23:15PM -0400, David Miller wrote:  
> > > +
> > > +	switch (act) {
> > > +	case XDP_TX:
> > > +		__skb_push(skb, skb->mac_len);  
> > 
> > s/skb->mac_len/mac_len/
> >   
> 
[...]
> 
> When using this change above suggested by Alexei, XDP_DROP and XDP_TX
> actions appear to work well with xdp1 and xdp2.

Also adjusted patch accordingly.

Ran a few quick tests today, but just against an really old e1000 NIC
attached to a PCI-bus (32bit).  There were not difference between DROP
and PASS, but this is likely due to a NIC HW limit.

Sender were sending 951,146 pps (<= tx_queue_0_packets /sec)

$ sudo ./xdp_bench01_mem_access_cost --readmem --action XDP_DROP --dev e1000
XDP_action   pps        pps-human-readable mem      
XDP_DROP     671975     671,975            read     
XDP_DROP     671997     671,997            read     
XDP_DROP     672061     672,061            read     
XDP_DROP     671861     671,861            read     
^CInterrupted: Removing XDP program on ifindex:2 device:e1000

$ sudo ./xdp_bench01_mem_access_cost --readmem --action XDP_PASS --dev e1000
XDP_action   pps        pps-human-readable mem      
XDP_PASS     672032     672,032            read     
XDP_PASS     671910     671,910            read     
XDP_PASS     671926     671,926            read     
XDP_PASS     671947     671,947            read     
^CInterrupted: Removing XDP program on ifindex:2 device:e1000

Program xdp_bench01_mem_access_cost avail here:
 https://github.com/netoptimizer/prototype-kernel/tree/master/kernel/samples/bpf

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
