From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [bug report] genetlink: fix error return code in genl_register_family()
Date: Wed, 9 Nov 2016 14:43:34 -0800
Message-ID: <CAM_iQpXySa6i6_Gtue1gbaHGZq5DG6SMvdO=ufGousUDKCGocw@mail.gmail.com>
References: <20161109095613.GA24471@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: weiyongjun1@huawei.com, kernel-janitors@vger.kernel.org,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:36285 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751550AbcKIWn4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2016 17:43:56 -0500
In-Reply-To: <20161109095613.GA24471@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cc'ing netdev

On Wed, Nov 9, 2016 at 1:56 AM, Dan Carpenter <dan.carpenter@oracle.com> wrote:
> Hello Wei Yongjun,
>
> The patch 22ca904ad70a: "genetlink: fix error return code in
> genl_register_family()" from Nov 1, 2016, leads to the following
> static checker warning:
>
>         net/netlink/genetlink.c:365 genl_register_family()
>         warn: unsigned 'family->id' is never less than zero.
>
> net/netlink/genetlink.c
>    362
>    363          family->id = idr_alloc(&genl_fam_idr, family,
>    364                                 start, end + 1, GFP_KERNEL);
>    365          if (family->id < 0) {
>                     ^^^^^^^^^^^^^^
> Doesn't work for unsigned int.


family->id should be signed int.
