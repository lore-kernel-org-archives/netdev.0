From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH] veth: don't assign a qdisc to veth
Date: Fri, 03 Oct 2014 13:51:59 -0700
Message-ID: <1412369519.17245.2.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20141003104858.6745.62964.stgit@dragon>
	 <CAHA+R7PMkNefxottnNOq+xhRVW_n+SXQxZYFXoNY1b_xEjWm5g@mail.gmail.com>
	 <20141003223816.6c56e6d8@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <cwang@twopensource.com>,
	netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jpirko@redhat.com>, mpatel@redhat.com
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:48570 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750750AbaJCUvc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Oct 2014 16:51:32 -0400
Received: by mail-pa0-f41.google.com with SMTP id eu11so2081447pac.28
        for <netdev@vger.kernel.org>; Fri, 03 Oct 2014 13:51:32 -0700 (PDT)
In-Reply-To: <20141003223816.6c56e6d8@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-10-03 at 22:38 +0200, Jesper Dangaard Brouer wrote:
> On Fri, 3 Oct 2014 09:53:16 -0700
> Cong Wang <cwang@twopensource.com> wrote:
> 
> > On Fri, Oct 3, 2014 at 3:48 AM, Jesper Dangaard Brouer
> > <brouer@redhat.com> wrote:
> > > The veth driver is a virtual device, and should not have assigned
> > > the default qdisc.  Verified (ndo_start_xmit) veth_xmit can only
> > > return NETDEV_TX_OK, thus this should be safe to bypass qdisc.
> > >
> > > Not assigning a qdisc is subtly done by setting tx_queue_len to zero.
> > >
> > 
> > Huh?? Maybe your $subject is too misleading, but we do use HTB
> > on veth, this will break our code since we will have to set tx_queue_len
> > after your patch, no?
> 
> No, you HTB setup should still work.

Unfortunately no....

Default htb classes are pfifo, and this uses device txqueuelen as
default limit.

So your change should have been done years ago.

Now its too late as it can break existing user scripts.
