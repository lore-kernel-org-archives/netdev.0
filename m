From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 2/3] bpf: Add new cgroups prog type to enable
 sock modifications
Date: Wed, 26 Oct 2016 14:42:09 -0600
Message-ID: <35265f1e-67ba-bd91-9583-00f39ffd07f2@cumulusnetworks.com>
References: <1477434613-3169-1-git-send-email-dsa@cumulusnetworks.com>
 <1477434613-3169-3-git-send-email-dsa@cumulusnetworks.com>
 <580FEA98.1090809@iogearbox.net>
 <CAF2d9jhE0OHgWrDfHwYzRk2tDbnmK_=ZdgFd2-ccpbTjdQzqmQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: linux-netdev <netdev@vger.kernel.org>, daniel@zonque.org,
        ast@fb.com
To: =?UTF-8?B?TWFoZXNoIEJhbmRld2FyICjgpK7gpLngpYfgpLYg4KSs4KSC4KSh4KWH4KS1?=
         =?UTF-8?B?4KS+4KSwKQ==?= <maheshb@google.com>,
        Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:35240 "EHLO
        mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932768AbcJZUmM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Oct 2016 16:42:12 -0400
Received: by mail-pf0-f177.google.com with SMTP id s8so2795617pfj.2
        for <netdev@vger.kernel.org>; Wed, 26 Oct 2016 13:42:11 -0700 (PDT)
In-Reply-To: <CAF2d9jhE0OHgWrDfHwYzRk2tDbnmK_=ZdgFd2-ccpbTjdQzqmQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/26/16 2:31 PM, Mahesh Bandewar (महेश बंडेवार) wrote:
> The hook insertion in sk_alloc() may not solve all control-path checks as not much can be done (probably apart for changing sk_bound_dev_if) during allocation but hooks in bind(), listen(), setsockopt() etc. (not a complete list) will be needed. Also pushing this change (changing sk_bound_dev_if) later (than sk_alloc()) you might avoid the case dumazet@ has mentioned.

For v2 I moved the running of the filter to the end of inet{6}_create.
