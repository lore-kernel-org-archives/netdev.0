From: Cong Wang <cwang@twopensource.com>
Subject: Re: Default network namespace name
Date: Wed, 21 May 2014 10:29:47 -0700
Message-ID: <CAHA+R7OKEri7yaSbbObbqERsoW+yvP0Txerg6iM6bXDtnYXzUw@mail.gmail.com>
References: <alpine.BSF.2.00.1405210826570.47766@nic-i.leissner.se>
	<CAKoUAr=68yxKqmPx8u9bfE8a-_bnonGZw-FcD=p-bw6=OARZ8A@mail.gmail.com>
	<alpine.BSF.2.00.1405211908090.47766@nic-i.leissner.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Rami Rosen <roszenrami@gmail.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Netdev <netdev@vger.kernel.org>
To: Peter Fassberg <pf@leissner.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f173.google.com ([209.85.216.173]:60540 "EHLO
	mail-qc0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752796AbaEUR3s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 May 2014 13:29:48 -0400
Received: by mail-qc0-f173.google.com with SMTP id i8so3632475qcq.4
        for <netdev@vger.kernel.org>; Wed, 21 May 2014 10:29:47 -0700 (PDT)
In-Reply-To: <alpine.BSF.2.00.1405211908090.47766@nic-i.leissner.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 21, 2014 at 10:21 AM, Peter Fassberg <pf@leissner.se> wrote:
>
> How does "ip link set" distinguish between PID 1 and a namespace named "1"?

Looking at the code, it just checks if it's name "1" first, then
checks if it's a PID:

                        if ((netns = get_netns_fd(*argv)) >= 0)
                                addattr_l(&req->n, sizeof(*req),
IFLA_NET_NS_FD, &netns, 4);
                        else if (get_integer(&netns, *argv, 0) == 0)
                                addattr_l(&req->n, sizeof(*req),
IFLA_NET_NS_PID, &netns, 4);
                        else
                                invarg("Invalid \"netns\" value\n", *argv);
