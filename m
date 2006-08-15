From: Hasso Tepper <hasso@estpak.ee>
Subject: Re: [PATCH 09/16] [IPv6] address: Convert address notification to use rtnl_notify()
Date: Tue, 15 Aug 2006 10:20:26 +0300
Message-ID: <200608151020.26836.hasso@estpak.ee>
References: <20060814213718.580598840@postel.suug.ch> <1155598991.6946.42.camel@jzny2> <1155599469.6946.46.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Thomas Graf <tgraf@suug.ch>, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from test.estpak.ee ([194.126.115.47]:62441 "EHLO devy.estpak.ee")
	by vger.kernel.org with ESMTP id S965268AbWHOHUa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2006 03:20:30 -0400
To: hadi@cyberus.ca
In-Reply-To: <1155599469.6946.46.camel@jzny2>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> CCing Hasso Tepper <hasso@estpak.ee>
>
> Hasso, please comment on this thread (apologies, I forgot the other
> guy's name; so if you can CC all the necessary suspects to comment, it
> would help).

I fully agree with Herbert Xu:

> The pid field in the netlink header should be treated as an opaque 
> value.  Any attempt to interpret it as the process ID is doomed to 
> failure. 

Zebra, Quagga and Xorp treat the pid field in the netlink header as 
unicast address of the netlink socket. As far as I know, that was the 
original idea:

http://marc.theaimsgroup.com/?l=linux-netdev&m=113943269432327&w=2

So, for Zebra, Quagga and Xorp users removals of current->pid mean just 
closing potential races. You can't quarantee that ip/route/ifconfig will 
not have the pid equal to the address of the netlink socket 
Zebra/Quagga/Xorp owns.


regards,

-- 
Hasso
