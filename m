From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 2/3] bpf: Add new cgroups prog type to enable
 sock modifications
Date: Tue, 25 Oct 2016 20:38:48 -0600
Message-ID: <c19dfdf7-425d-cf47-6afc-c9433cbc06cf@cumulusnetworks.com>
References: <1477434613-3169-1-git-send-email-dsa@cumulusnetworks.com>
 <1477434613-3169-3-git-send-email-dsa@cumulusnetworks.com>
 <580FEA98.1090809@iogearbox.net>
 <20161026015544.GA35758@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@zonque.org, ast@fb.com
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:34141 "EHLO
        mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750749AbcJZCj0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Oct 2016 22:39:26 -0400
Received: by mail-pf0-f178.google.com with SMTP id n85so13536383pfi.1
        for <netdev@vger.kernel.org>; Tue, 25 Oct 2016 19:38:51 -0700 (PDT)
In-Reply-To: <20161026015544.GA35758@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/25/16 7:55 PM, Alexei Starovoitov wrote:
> Same question as Daniel... why extra helper?

It can be dropped. wrong path while learning this code.

> If program overwrites bpf_sock->sk_bound_dev_if can we use that
> after program returns?
> Also do you think it's possible to extend this patch to prototype
> the port bind restrictions that were proposed few month back using
> the same bpf_sock input structure?
> Probably the check would need to be moved into different
> place instead of sk_alloc(), but then we'll have more
> opportunities to overwrite bound_dev_if, look at ports and so on ?
> 

I think the sk_bound_dev_if should be set when the socket is created versus waiting until it is used (bind, connect, sendmsg, recvmsg). That said, the filter could (should?) be run in the protocol family create function (inet_create and inet6_create) versus sk_alloc. That would allow the filter to allocate a local port based on its logic. I'd prefer interested parties to look into the details of that use case.

I'll move the running of the filter to the end of the create functions for v2.
