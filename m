From: Tejun Heo <htejun@fb.com>
Subject: Re: [RFC PATCH 4/5] net: filter: run cgroup eBPF programs
Date: Thu, 25 Aug 2016 15:37:37 -0400
Message-ID: <20160825193733.GA697@htj.duckdns.org>
References: <1471442448-1248-1-git-send-email-daniel@zonque.org>
 <1471442448-1248-5-git-send-email-daniel@zonque.org>
 <20160821201421.GA5753@ircssh.c.rugged-nimbus-611.internal>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Daniel Mack <daniel@zonque.org>, <daniel@iogearbox.net>,
        <ast@fb.com>, <davem@davemloft.net>, <kafai@fb.com>,
        <fw@strlen.de>, <pablo@netfilter.org>, <harald@redhat.com>,
        <netdev@vger.kernel.org>
To: Sargun Dhillon <sargun@sargun.me>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:2174 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1757177AbcHYUO7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2016 16:14:59 -0400
Content-Disposition: inline
In-Reply-To: <20160821201421.GA5753@ircssh.c.rugged-nimbus-611.internal>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello, Sargun.

On Sun, Aug 21, 2016 at 01:14:22PM -0700, Sargun Dhillon wrote:
> So, casually looking at this patch, it looks like you're relying on 
> sock_cgroup_data, which only points to the default hierarchy. If someone uses 
> net_prio or net_classid, cgroup_sk_alloc_disable is called, and this wont work 
> anymore. 

The requirement there comes from network side.  In short, davem
(rightfuly) doesn't want further proliferation of cgroup association
fields in struct sock.  It makes sense for network control too as it's
schizophrenic to have different associations depending on the specific
controller.  Also, the v2 requirement shouldn't really get in the way
as it can be mounted as just another hierarchy along with other v1
hierarchies.

> Any ideas on how to work around that? Does it make sense to add another pointer 
> to sock_cgroup_data, or at least a warning when allocation is disabled?

cgroup already warns when the association gets disabled due to usage
of netcls and netprio.  We probably want to update the warning message
to include bpf too.

Thanks.

-- 
tejun
