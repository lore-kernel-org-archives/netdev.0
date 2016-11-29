From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v5 2/3] bpf: Add new cgroup attach type to enable
 sock modifications
Date: Tue, 29 Nov 2016 14:01:44 -0700
Message-ID: <04ddcbeb-aa5e-5329-4830-73434a7a8b75@cumulusnetworks.com>
References: <1480434813-3141-1-git-send-email-dsa@cumulusnetworks.com>
 <1480434813-3141-3-git-send-email-dsa@cumulusnetworks.com>
 <20161129200141.GB24152@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@zonque.org, ast@fb.com,
        daniel@iogearbox.net, maheshb@google.com, tgraf@suug.ch
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:34012 "EHLO
        mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753933AbcK2VBq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 16:01:46 -0500
Received: by mail-pf0-f174.google.com with SMTP id c4so33953064pfb.1
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2016 13:01:46 -0800 (PST)
In-Reply-To: <20161129200141.GB24152@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/29/16 1:01 PM, Alexei Starovoitov wrote:
> Could you also expose sk_protcol and sk_type as read only fields?
> They have user space visible values already and will make this new
> BPF_PROG_TYPE_CGROUP_SOCK program type much more useful beyond vrf
> use case. Like we'll be able to write a tiny bpf program to block all
> raw sockets or all udp sockets for an application within a given cgroup.
> If someone would want to prevent udp traffic from an application,
> it can be done here within close to zero overhead for socket() syscall
> instead of checking every packet at networking layer.
> It can help vrf use case as well, so you can auto-bindtodevice
> only udp and tcp sockets instead of all... or do it for ipv4 or ipv6 only.
> Plenty of interesting opportunities with just two extra fields
> that cost nothing when not in use.

sure. for completeness I'll add sk_family too.
