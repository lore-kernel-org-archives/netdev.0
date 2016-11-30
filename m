From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next v5 2/3] bpf: Add new cgroup attach type to
 enable sock modifications
Date: Tue, 29 Nov 2016 21:41:56 -0800
Message-ID: <20161130054154.GC31581@ast-mbp.thefacebook.com>
References: <1480434813-3141-1-git-send-email-dsa@cumulusnetworks.com>
 <1480434813-3141-3-git-send-email-dsa@cumulusnetworks.com>
 <20161129200141.GB24152@ast-mbp.thefacebook.com>
 <781e66b2-007c-bd56-2cd1-543c1f5dcdb7@cumulusnetworks.com>
 <20161130005906.GB29591@ast-mbp.thefacebook.com>
 <d3359d0c-8995-d605-cd2d-f0558fdd0408@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, daniel@zonque.org, ast@fb.com,
        daniel@iogearbox.net, maheshb@google.com, tgraf@suug.ch
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:36339 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751498AbcK3Fm3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 00:42:29 -0500
Received: by mail-pf0-f195.google.com with SMTP id c4so9527821pfb.3
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2016 21:42:02 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <d3359d0c-8995-d605-cd2d-f0558fdd0408@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 29, 2016 at 06:07:18PM -0700, David Ahern wrote:
> On 11/29/16 5:59 PM, Alexei Starovoitov wrote:
> > On Tue, Nov 29, 2016 at 05:43:08PM -0700, David Ahern wrote:
> >> On 11/29/16 1:01 PM, Alexei Starovoitov wrote:
> >>> Could you also expose sk_protcol and sk_type as read only fields?
> >>
> >> Those are bitfields in struct sock, so can't use offsetof or sizeof. Any existing use cases that try to load a bitfield in a bpf that I can look at?
> > 
> > pkt_type, vlan are also bitfileds in skb. Please see convert_skb_access()
> > There is a bit of ugliness due to __BIG_ENDIAN_BITFIELD though..
> > 
> 
> Given the added complexity I'd prefer to defer this second use case to a follow on patch set. This one introduces the infra for sockets and I don't see anything needing to change with it to add the read of 3 more sock elements. Agree?

I don't see a complexity. It was straightforward for skb bitfields,
but if there is some unforeseen issue, it's better to tackle it now
otherwise the feature may never come and this 'infra for sockets' will
stay as 'infra for vrf only' and I'm struggling to convince myself that it's ok.
So I'll try to tweak this patch to add these 3 fields...
