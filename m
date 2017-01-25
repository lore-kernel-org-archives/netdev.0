From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH v2] bpf: Restrict cgroup bpf hooks to the init netns
Date: Tue, 24 Jan 2017 17:19:07 -0700
Message-ID: <46649e97-dc4a-b6ab-94f9-45727c74c061@cumulusnetworks.com>
References: <20170124020950.GA72992@ast-mbp.thefacebook.com>
 <CALCETrUq_ZSso_252ixzjt+WbFOv_K57zbePUXneLv-Tgi5=jA@mail.gmail.com>
 <20170124031259.GA81720@ast-mbp.thefacebook.com>
 <CALCETrVZqqfMO+=HGgebbAJ0TY6c3XSyY1G-Ve+g3VQiEfGwyA@mail.gmail.com>
 <08f3f57e-8c51-c893-01ad-3ce23db8166d@cumulusnetworks.com>
 <CALCETrVsqktjiPkfpcm_5uL0UL2Lzr106ZteLchJVnsKH_e-aw@mail.gmail.com>
 <20170124174823.GA17813@ast-mbp.thefacebook.com>
 <CALCETrW-Sj9eM+Nm9PVpqJky_30YSGhzc8hnzmddPkhHzb5_Fg@mail.gmail.com>
 <242993d5-e27c-7177-a021-610d16b150e4@cumulusnetworks.com>
 <CALCETrXzh-7BJ4Q_oG0hBkTdK+XgDWUYe0=gLwkqG6sncskv3g@mail.gmail.com>
 <20170125001130.GA37299@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Tejun Heo <tj@kernel.org>, Andy Lutomirski <luto@kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Alexei Starovoitov <ast@kernel.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Andy Lutomirski <luto@amacapital.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:34461 "EHLO
        mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750902AbdAYATJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 19:19:09 -0500
Received: by mail-pf0-f177.google.com with SMTP id e4so53348435pfg.1
        for <netdev@vger.kernel.org>; Tue, 24 Jan 2017 16:19:09 -0800 (PST)
In-Reply-To: <20170125001130.GA37299@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/24/17 5:11 PM, Alexei Starovoitov wrote:
> I think bpf_get_sock_netns_id() helper or sk->netns_id field would
> be good addition as well, since it will allow 'ip vrf' to be smarter today.
> It's also more flexible, since bpf_type_cgroup_sock program can make
> its own decision when netns_id != expecte_id instead of hard coded.
> Today the ip vrf use case does: 'sk->bound_dev_if = idx; return OK;'
> it will be able to:
>   if (sk->netns_id != expected_id)
>     return DROP;
>   sk->bound_dev_if = idx;
>   return OK;
> or
>   if (sk->netns_id != expected_id)
>     return OK;
>   sk->bound_dev_if = idx;
>   return OK;

I agree
