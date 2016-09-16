From: Florian Westphal <fw@strlen.de>
Subject: Re: [netfilter-core] [lkp] [netfilter] 68263ddb47: WARNING: CPU: 0
 PID: 1225 at net/netfilter/nf_conntrack_seqadj.c:232
 nf_ct_seq_offset+0x7a/0x9a
Date: Fri, 16 Sep 2016 19:18:27 +0200
Message-ID: <20160916171827.GE5204@breakpoint.cc>
References: <1472780905-13094-1-git-send-email-fgao@ikuai8.com>
 <20160916140449.GB7764@yexl-desktop>
 <CA+6hz4o_Jub=zUcnXjy=oXS_5uZkxxw2Jv7p2FvdMqHV0pg+hw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kernel test robot <xiaolong.ye@intel.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        coreteam@netfilter.org,
        Netfilter Developer Mailing List
        <netfilter-devel@vger.kernel.org>, lkp@01.org
To: Gao Feng <fgao@ikuai8.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:49028 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1758479AbcIPRSw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Sep 2016 13:18:52 -0400
Content-Disposition: inline
In-Reply-To: <CA+6hz4o_Jub=zUcnXjy=oXS_5uZkxxw2Jv7p2FvdMqHV0pg+hw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Gao Feng <fgao@ikuai8.com> wrote:
> > [   23.465616] ------------[ cut here ]------------
> > [   23.466477] WARNING: CPU: 0 PID: 1225 at net/netfilter/nf_conntrack_seqadj.c:232
> > nf_ct_seq_offset+0x7a/0x9a
> > [   23.468458] Missing nfct_seqadj_ext_add() setup call
> >
> 
> It should be that nf_ct_add_synproxy failed and the seqadj extentision is
> not added.

Note that nfct_synproxy_ext_add always returns NULL if
CONFIG_NETFILTER_SYNPROXY=n

The warning should also be removed.

> When nf_ct_add_synproxy fails, the init_conntrack fails too and return
> ERR_PTR(-ENOMEM). In this case, the packet should be dropped directly, and
> should not be processed by the latter codes.

This means the commit breaks conntrack if SYNPROXY=n
