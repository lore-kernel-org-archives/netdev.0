From: Samuel Ortiz <samuel@sortiz.org>
Subject: Re: Generic netlink interface help
Date: Mon, 28 May 2007 17:01:10 +0300
Message-ID: <20070528140110.GA3733@sortiz.org>
References: <84po8XY4.1179999810.5490870.samuel@sortiz.org> <1180024477.18003.11.camel@johannes.berg> <20070525221802.GO521@postel.suug.ch> <1180272296.3604.64.camel@johannes.berg> <20070527135014.GQ21180@enneenne.com> <1180274071.3604.66.camel@johannes.berg> <20070527174759.GV21180@enneenne.com>
Reply-To: Samuel Ortiz <samuel@sortiz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes@sipsolutions.net>,
	Thomas Graf <tgraf@suug.ch>, netdev@vger.kernel.org
To: Rodolfo Giometti <giometti@enneenne.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 42.mail-out.ovh.net ([213.251.189.42]:46339 "HELO
	42.mail-out.ovh.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1750779AbXE1OKd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 May 2007 10:10:33 -0400
Content-Disposition: inline
In-Reply-To: <20070527174759.GV21180@enneenne.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, May 27, 2007 at 07:47:59PM +0200, Rodolfo Giometti wrote:
> On Sun, May 27, 2007 at 03:54:30PM +0200, Johannes Berg wrote:
> 
> > It's written in python without using libnl:
> > http://git.sipsolutions.net/pynl80211.git
> 
> If I well understand I should do something like this:
> 
> 	s = socket(PF_NETLINK, SOCK_RAW, NETLINK_GENERIC);
> 
>         memset(&src_addr, 0, sizeof(src_addr));
>         src_addr.nl_family = AF_NETLINK;
>         src_addr.nl_pid = 0;            /* ask kernel to choose an unique ID */
>         src_addr.nl_groups = 0;         /* not in mcast groups */
>         ret = bind(handle->socket, (struct sockaddr *) &src_addr, sizeof(src_add
> 
> to get access to the generic netlink, then I should request the
> generic family name but I don't understand in which structure I should
> put this request... Can you please halp me?
You should first fetch your attributed family ID by sending a generic
netlink request (CTRL_CMD_GETFAMILY) to the generic netlink control family (GENL_ID_CTRL).
Once you have your family ID, you can build generic netlink messages and
send them there.
I'm linking with libnl, but you can have a look at my irconfig draft at
http://sortiz.org/irda/irconfig.c

Cheers,
Samuel.


> Thanks a lot,
> 
> Rodolfo
> 
> -- 
> 
> GNU/Linux Solutions                  e-mail:    giometti@enneenne.com
> Linux Device Driver                             giometti@gnudd.com
> Embedded Systems                     		giometti@linux.it
> UNIX programming                     phone:     +39 349 2432127
