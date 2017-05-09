From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] tcp: do not inherit mc_list from parent
Date: Tue, 09 May 2017 06:23:35 -0700
Message-ID: <1494336215.7796.75.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1494332235.7796.70.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Pray3r <pray3r.z@gmail.com>,
        Andrey Konovalov <andreyknvl@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:34175 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751210AbdEINXh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 9 May 2017 09:23:37 -0400
Received: by mail-pf0-f181.google.com with SMTP id e64so130622pfd.1
        for <netdev@vger.kernel.org>; Tue, 09 May 2017 06:23:37 -0700 (PDT)
In-Reply-To: <1494332235.7796.70.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-05-09 at 05:17 -0700, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> syzkaller found a way to trigger double frees from ip_mc_drop_socket()
> 
> It turns out that leave a copy of parent mc_list at accept() time,
> which is very bad.
> 
> Very similar to commit 8b485ce69876 ("tcp: do not inherit
> fastopen_req from parent")
> 
> Initial report from Pray3r, completed by Andrey one.
> Thanks a lot to them !
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Pray3r <pray3r.z@gmail.com>
> Reported-by: Andrey Konovalov <andreyknvl@google.com>
> Tested-by: Andrey Konovalov <andreyknvl@google.com>
> ---
> Notes:
>  - day-0 bug.
>  - Not sure if it makes sense for TCP socket to be able to join MC
> group ?


I will send a V2, putting the fix in inet_csk_clone_lock() so that DCCP
is also fixed ;)
