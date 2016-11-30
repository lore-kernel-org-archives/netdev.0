From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next v5 2/3] bpf: Add new cgroup attach type to
 enable sock modifications
Date: Tue, 29 Nov 2016 16:59:07 -0800
Message-ID: <20161130005906.GB29591@ast-mbp.thefacebook.com>
References: <1480434813-3141-1-git-send-email-dsa@cumulusnetworks.com>
 <1480434813-3141-3-git-send-email-dsa@cumulusnetworks.com>
 <20161129200141.GB24152@ast-mbp.thefacebook.com>
 <781e66b2-007c-bd56-2cd1-543c1f5dcdb7@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, daniel@zonque.org, ast@fb.com,
        daniel@iogearbox.net, maheshb@google.com, tgraf@suug.ch
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:36073 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753383AbcK3A7M (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 19:59:12 -0500
Received: by mail-pf0-f193.google.com with SMTP id c4so9105142pfb.3
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2016 16:59:12 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <781e66b2-007c-bd56-2cd1-543c1f5dcdb7@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 29, 2016 at 05:43:08PM -0700, David Ahern wrote:
> On 11/29/16 1:01 PM, Alexei Starovoitov wrote:
> > Could you also expose sk_protcol and sk_type as read only fields?
> 
> Those are bitfields in struct sock, so can't use offsetof or sizeof. Any existing use cases that try to load a bitfield in a bpf that I can look at?

pkt_type, vlan are also bitfileds in skb. Please see convert_skb_access()
There is a bit of ugliness due to __BIG_ENDIAN_BITFIELD though..
