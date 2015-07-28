From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net] bridge: mdb: fix delmdb state in the notification
Date: Tue, 28 Jul 2015 15:38:21 -0700
Message-ID: <CAHA+R7NJod_=R=Hh2Mz7nMiTxCMv=E4TMLsn2uOrS+f9gp+uHQ@mail.gmail.com>
References: <1438081844-18801-1-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	"bridge@lists.linux-foundation.org"
	<bridge@lists.linux-foundation.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Cong Wang <amwang@redhat.com>,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: Nikolay Aleksandrov <razor@blackwall.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f172.google.com ([209.85.160.172]:33657 "EHLO
	mail-yk0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751131AbbG1WiV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2015 18:38:21 -0400
Received: by ykba194 with SMTP id a194so5692101ykb.0
        for <netdev@vger.kernel.org>; Tue, 28 Jul 2015 15:38:21 -0700 (PDT)
In-Reply-To: <1438081844-18801-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 28, 2015 at 4:10 AM, Nikolay Aleksandrov
<razor@blackwall.org> wrote:
> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>
> Since mdb states were introduced when deleting an entry the state was
> left as it was set in the delete request from the user which leads to
> the following output when doing a monitor (for example):
> $ bridge mdb add dev br0 port eth3 grp 239.0.0.1 permanent
> (monitor) dev br0 port eth3 grp 239.0.0.1 permanent
> $ bridge mdb del dev br0 port eth3 grp 239.0.0.1 permanent
> (monitor) dev br0 port eth3 grp 239.0.0.1 temp
> ^^^
> Note the "temp" state in the delete notification which is wrong since
> the entry was permanent, the state in a delete is always reported as
> "temp" regardless of the real state of the entry.
>

Hmm?

I think it is iproute2 who forgets to set entry->state when deleting it?

                } else if (strcmp(*argv, "permanent") == 0) {
                        if (cmd == RTM_NEWMDB)
                                entry.state |= MDB_PERMANENT;

Kernel simply returns what you pass to it.

Please fix iproute2.
