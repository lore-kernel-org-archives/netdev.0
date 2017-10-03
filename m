From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 1/8] bpf: multi program support for cgroup+bpf
Date: Mon, 2 Oct 2017 21:26:36 -0700
Message-ID: <1211d4c0-b812-af08-cbd4-72eb9259ee78@cumulusnetworks.com>
References: <20171002234857.3707580-1-ast@fb.com>
 <20171002234857.3707580-2-ast@fb.com>
 <71bda584-d828-7472-7655-85a454dbe297@cumulusnetworks.com>
 <f5d34464-42a9-b51b-edc4-06c44b3c4845@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>, Tejun Heo <tj@kernel.org>,
        netdev@vger.kernel.org, kernel-team@fb.com
To: Alexei Starovoitov <ast@fb.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:51867 "EHLO
        mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750708AbdJCE0h (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Oct 2017 00:26:37 -0400
Received: by mail-pf0-f174.google.com with SMTP id n14so2084931pfh.8
        for <netdev@vger.kernel.org>; Mon, 02 Oct 2017 21:26:37 -0700 (PDT)
In-Reply-To: <f5d34464-42a9-b51b-edc4-06c44b3c4845@fb.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/2/17 9:21 PM, Alexei Starovoitov wrote:
> 
> i'm not sure what you're trying to say.
> The first loop quoted above is inside cgroup_bpf_put()
> which is called when cgroup is destroyed. At this point
> we're detaching and prog_put all attached programs.
> While there is only one static_branch_inc() in __cgroup_bpf_attach()
> that is called every time the prog is attached to a cgroup.
> So what's the concern?

just asking if cgroup_bpf_enabled_key is 0 when all programs are removed
-- ie., that the inc's and dec's are equal. Reviewing this patch it was
not clear that they are.

> Note we're doing branch_dec only for progs in prog_list.
> Just like we do branch_inc only for progs in prog_list.
> Computing prog_array doesn't involve manipulations with prog's refcnt
> and no branch_inc/dec either.
> 
