From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute PATCH] lib/bpf: Fix bytecode-file parsing
Date: Mon, 4 Sep 2017 12:09:06 -0700
Message-ID: <20170904120907.4c2221b2@xeon-e3>
References: <20170829150945.7077-1-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f49.google.com ([74.125.83.49]:33137 "EHLO
        mail-pg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753932AbdIDTJO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 4 Sep 2017 15:09:14 -0400
Received: by mail-pg0-f49.google.com with SMTP id t3so3386603pgt.0
        for <netdev@vger.kernel.org>; Mon, 04 Sep 2017 12:09:14 -0700 (PDT)
In-Reply-To: <20170829150945.7077-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 29 Aug 2017 17:09:45 +0200
Phil Sutter <phil@nwl.cc> wrote:

> The signedness of char type is implementation dependent, and there are
> architectures on which it is unsigned by default. In that case, the
> check whether fgetc() returned EOF failed because the return value was
> assigned an (unsigned) char variable prior to comparison with EOF (which
> is defined to -1). Fix this by using int as type for 'c' variable, which
> also matches the declaration of fgetc().
> 
> While being at it, fix the parser logic to correctly handle multiple
> empty lines and consecutive whitespace and tab characters to further
> improve the parser's robustness. Note that this will still detect double
> separator characters, so doesn't soften up the parser too much.
> 
> Fixes: 3da3ebfca85b8 ("bpf: Make bytecode-file reading a little more robust")
> Cc: Daniel Borkmann <daniel@iogearbox.net>
> Signed-off-by: Phil Sutter <phil@nwl.cc>

Looks fine applied.

Although I think only Android is using unsigned for char type at this point.
