From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] fix NULL pointer dereference in br_handle_frame
Date: Thu, 12 Sep 2013 09:08:58 -0700
Message-ID: <1379002138.24408.17.camel@edumazet-glaptop>
References: <1378988195-2710-1-git-send-email-zhiguohong@tencent.com>
	   <1378995112.24408.4.camel@edumazet-glaptop>
	   <CAA7+ByWJLUkxy7C0frKOFUscJaQyRLsfk_N=NZfdzUrbZ=4MNA@mail.gmail.com>
	  <1378996396.24408.8.camel@edumazet-glaptop> <5231D2D2.3090907@redhat.com>
	 <1378999470.24408.10.camel@edumazet-glaptop> <5231E2C7.1010106@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Hong zhi guo <honkiko@gmail.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>, zhiguohong@tencent.com
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:45818 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753939Ab3ILQJD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Sep 2013 12:09:03 -0400
Received: by mail-pd0-f177.google.com with SMTP id y10so5935pdj.22
        for <netdev@vger.kernel.org>; Thu, 12 Sep 2013 09:09:02 -0700 (PDT)
In-Reply-To: <5231E2C7.1010106@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-09-12 at 11:50 -0400, Vlad Yasevich wrote:
> On 09/12/2013 11:24 AM, Eric Dumazet wrote:
> > On Thu, 2013-09-12 at 10:42 -0400, Vlad Yasevich wrote:
> >
> >> Don't all tests for IFF_BRIDGE_PORT on the bridge receive path become
> >> redundant as well?
> >
> > Sure but anyway this part is net-next material
> >
> > Lets fix the bug first.
> 
> Seems like the race is possible in net as well.  If we just include the
> original patch, then br_add_if() also has to be modified to make sure
> the flag is set properly before netdev_rx_handler_register() is called.
> 
> If we remove the need to check the flag during bridge input handling,
> then br_add_if() change is not necessary.

Yep, really testing IFF_BRIDGE_PORT in fast path is currently racy.

rcu protection should be enough.
