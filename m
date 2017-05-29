From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: vxlan: use after free error
Date: Mon, 29 May 2017 08:32:47 -0700
Message-ID: <20170529083247.12b1cb60@xeon-e3>
References: <03ac7d79-02b7-4bee-d318-9731413bf97b@mellanox.com>
        <CAJieiUhNV7=r53mmsHTHAmA8g0PKoxszHyNMXwYKG4OsB20KjQ@mail.gmail.com>
        <b04f5f7e-dca1-b219-eb52-03f58fd3823e@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Roopa Prabhu <roopa@cumulusnetworks.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        Jiri Benc <jbenc@redhat.com>, pravin shelar <pshelar@ovn.org>,
        Alexander Duyck <aduyck@mirantis.com>,
        Nicolas Dichtel <nicolas.dichtel@6wind.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Balki Raman <ramanb@cumulusnetworks.com>
To: Mark Bloch <markb@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f44.google.com ([74.125.83.44]:34895 "EHLO
        mail-pg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751128AbdE2Pcu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 May 2017 11:32:50 -0400
Received: by mail-pg0-f44.google.com with SMTP id 8so24349231pgc.2
        for <netdev@vger.kernel.org>; Mon, 29 May 2017 08:32:50 -0700 (PDT)
In-Reply-To: <b04f5f7e-dca1-b219-eb52-03f58fd3823e@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 29 May 2017 09:28:52 +0300
Mark Bloch <markb@mellanox.com> wrote:

> In my patch I've added the code inside vxlan_sock_release()
> after we do:
>         rcu_assign_pointer(vxlan->vn6_sock, NULL);
>         rcu_assign_pointer(vxlan->vn4_sock, NULL);

Use RCU_INIT_POINTER when assigning NULL. A barrier is not necessary.
