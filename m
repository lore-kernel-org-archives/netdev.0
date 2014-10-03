From: Cong Wang <cwang@twopensource.com>
Subject: Re: [net-next PATCH] veth: don't assign a qdisc to veth
Date: Fri, 3 Oct 2014 09:53:16 -0700
Message-ID: <CAHA+R7PMkNefxottnNOq+xhRVW_n+SXQxZYFXoNY1b_xEjWm5g@mail.gmail.com>
References: <20141003104858.6745.62964.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jpirko@redhat.com>, mpatel@redhat.com
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f169.google.com ([209.85.217.169]:44844 "EHLO
	mail-lb0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753329AbaJCQxS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Oct 2014 12:53:18 -0400
Received: by mail-lb0-f169.google.com with SMTP id 10so1355239lbg.28
        for <netdev@vger.kernel.org>; Fri, 03 Oct 2014 09:53:17 -0700 (PDT)
In-Reply-To: <20141003104858.6745.62964.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 3, 2014 at 3:48 AM, Jesper Dangaard Brouer
<brouer@redhat.com> wrote:
> The veth driver is a virtual device, and should not have assigned
> the default qdisc.  Verified (ndo_start_xmit) veth_xmit can only
> return NETDEV_TX_OK, thus this should be safe to bypass qdisc.
>
> Not assigning a qdisc is subtly done by setting tx_queue_len to zero.
>

Huh?? Maybe your $subject is too misleading, but we do use HTB
on veth, this will break our code since we will have to set tx_queue_len
after your patch, no?
