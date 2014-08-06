From: Cong Wang <cwang@twopensource.com>
Subject: Re: linux-next: net/netlink/diag.c:106 suspicious rcu_dereference_protected()
 usage!
Date: Wed, 6 Aug 2014 10:52:01 -0700
Message-ID: <CAHA+R7N0c83by=AAgw2nKPibYETNyv6JTEWnu5XOo-67fHMELw@mail.gmail.com>
References: <CANaxB-ySsRXHPSEPOuExeKAvDX7esZ1WBZAVMTWQxtmfN2=i4w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, Thomas Graf <tgraf@suug.ch>
To: Andrey Wagin <avagin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f45.google.com ([209.85.215.45]:58434 "EHLO
	mail-la0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752027AbaHFRwD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Aug 2014 13:52:03 -0400
Received: by mail-la0-f45.google.com with SMTP id ty20so2516439lab.4
        for <netdev@vger.kernel.org>; Wed, 06 Aug 2014 10:52:01 -0700 (PDT)
In-Reply-To: <CANaxB-ySsRXHPSEPOuExeKAvDX7esZ1WBZAVMTWQxtmfN2=i4w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 6, 2014 at 10:29 AM, Andrey Wagin <avagin@gmail.com> wrote:
> [   40.072199] ===============================
> [   40.072350] [ INFO: suspicious RCU usage. ]
> [   40.072501] 3.16.0-next-20140806 #1 Not tainted
> [   40.072659] -------------------------------
> [   40.072807] net/netlink/diag.c:106 suspicious
> rcu_dereference_protected() usage!
> [   40.073047]
> other info that might help us debug this:
>
> [   40.073276]
> rcu_scheduler_active = 1, debug_locks = 0
> [   40.073494] 4 locks held by criu/2838:
> [   40.073635]  #0:  (sock_diag_mutex){+.+.+.}, at:
> [<ffffffff81689afb>] sock_diag_rcv+0x1b/0x40
> [   40.074226]  #1:  (sock_diag_table_mutex){+.+.+.}, at:
> [<ffffffff81689c6d>] sock_diag_rcv_msg+0x6d/0x140
> [   40.074803]  #2:  (nlk->cb_mutex){+.+.+.}, at: [<ffffffff816a28f1>]
> netlink_dump+0x21/0x2d0
> [   40.075382]  #3:  (nl_table_lock){.+.?..}, at: [<ffffffffa0286601>]
> netlink_diag_dump+0x31/0xb0 [netlink_diag]
> [   40.076351]


Looks like we should hold rcu_read_lock() before calling __netlink_diag_dump().
