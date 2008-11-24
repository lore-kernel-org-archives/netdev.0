From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: net-next/unix: BUG: using smp_processor_id() in preemptible
Date: Mon, 24 Nov 2008 10:41:47 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0811241039210.28478@wrl-59.cs.helsinki.fi>
References: <Pine.LNX.4.64.0811221634370.10534@wrl-59.cs.helsinki.fi>
 <4928CECE.602@cosmosbay.com> <20081123.172014.78676422.davem@davemloft.net>
 <20081123.173426.255648175.davem@davemloft.net> <492A5F6D.3040708@cosmosbay.com>
Mime-Version: 1.0
Content-Type: MULTIPART/Mixed; boundary="=_courier-23966-1227513720-0001-2"
Cc: David Miller <davem@davemloft.net>, Netdev <netdev@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:59400 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751107AbYKXIlt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2008 03:41:49 -0500
In-Reply-To: <492A5F6D.3040708@cosmosbay.com>
Content-ID: <Pine.LNX.4.64.0811241039211.28478@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--=_courier-23966-1227513720-0001-2
Content-Type: TEXT/PLAIN; charset=iso-8859-1; format=flowed
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0811241039212.28478@wrl-59.cs.helsinki.fi>

On Mon, 24 Nov 2008, Eric Dumazet wrote:

> David Miller a écrit :
> > From: David Miller <davem@davemloft.net>
> > Date: Sun, 23 Nov 2008 17:20:14 -0800 (PST)
> > 
> > > From: Eric Dumazet <dada1@cosmosbay.com>
> > > Date: Sun, 23 Nov 2008 04:32:30 +0100
> > >
> > > > [PATCH] net: make sock_prot_inuse_add() preempt safe
> >  ...
> > > Eric, you added this bug by starting to use this interface in
> > > situations where BH's were not disabled.
> > >
> > > Ever existing use adhered to that rule.
> > >
> > > If you therefore want to call this interface in new locations,
> > > you have to make sure those locations follow the rule too.
> > 
> > Here is what I commited to fix this bug.
> > 
> > net: Make sure BHs are disabled in sock_prot_inuse_add()
> > 
> > The rule of calling sock_prot_inuse_add() is that BHs must
> > be disabled.  Some new calls were added where this was not
> > true and this tiggers warnings as reported by Ilpo.
> > 
> > Fix this by adding explicit BH disabling around those call sites.
> > 
> > Signed-off-by: David S. Miller <davem@davemloft.net>
> > ---
> >  net/netlink/af_netlink.c |    3 +++
> >  net/sctp/socket.c        |    4 ++++
> >  net/unix/af_unix.c       |    2 ++
> >  3 files changed, 9 insertions(+), 0 deletions(-)
> 
> I believe some bits are missing
> 
> Ilpo report was about unix_create1() being preemptable for example

Yes, basically these two sites I got (during boot, I didn't look much 
further if I could have gotten them from somewhere else too):

$ grep -A1 '[]] sock_prot_inuse_add[+]' dmesg.log  | grep "fffff" | grep -v sock_prot_inuse_add | sort | uniq
 [<ffffffff80514cdd>] unix_create1+0x161/0x176
 [<ffffffff805151de>] unix_sock_destructor+0xb6/0xbc


-- 
 i.
--=_courier-23966-1227513720-0001-2--
