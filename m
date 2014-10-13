From: Cong Wang <cwang@twopensource.com>
Subject: Re: Fw: [Bug 86081] New: Can't free the return value of
 sock_kmalloc() when the value is NULL
Date: Mon, 13 Oct 2014 13:58:56 -0700
Message-ID: <CAHA+R7OgvPOM1GVQOU5eJreM2R5V-SxkO4nubVYoLdCvS_hUAQ@mail.gmail.com>
References: <20141012170756.19d1d12e@uryu.home.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andy Grover <andy.grover@oracle.com>,
	netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f42.google.com ([209.85.192.42]:39396 "EHLO
	mail-qg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751429AbaJMU65 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Oct 2014 16:58:57 -0400
Received: by mail-qg0-f42.google.com with SMTP id z60so7546745qgd.29
        for <netdev@vger.kernel.org>; Mon, 13 Oct 2014 13:58:56 -0700 (PDT)
In-Reply-To: <20141012170756.19d1d12e@uryu.home.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 12, 2014 at 8:07 AM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
>
> in function rds_cmsg_rdma_args() at net/rds/rdma.c:L546, the variable
> "iovstack" is an array and the pointer variable *iovs is equal to iovstack (at
> Line 554). As the the return value of sock_kmalloc() (called at line 578),when
> "iovs" is NULL, function sock_kfree_s() will be called(at line 697) and
> function sock_kfree_s() will free "iovs".
> The related code snippets in function rds_cmsg_rdma_args() are as followings.
> rds_cmsg_rdma_args() at net/rds/rdma.c:L546

Free'ing NULL is okay, but not sub'ing the sk_omem_alloc size.
I will send a patch.
