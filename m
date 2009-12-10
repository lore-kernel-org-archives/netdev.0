From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH 3/3] tcp: Slightly optimize tcp_sendmsg
Date: Thu, 10 Dec 2009 12:42:09 +0200 (EET)
Message-ID: <alpine.DEB.2.00.0912101227320.7024@wel-95.cs.helsinki.fi>
References: <20091209082613.19055.58864.sendpatchset@localhost.localdomain> <20091209082624.19055.99645.sendpatchset@localhost.localdomain> <alpine.DEB.2.00.0912101016040.23376@melkinpaasi.cs.helsinki.fi>
 <OFC615F4FC.74D9EC7D-ON65257688.003074DE-65257688.0038A471@in.ibm.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323329-1660665738-1260441729=:7024"
Cc: David Miller <davem@davemloft.net>, Netdev <netdev@vger.kernel.org>
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:45564 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933683AbZLJKmE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2009 05:42:04 -0500
In-Reply-To: <OFC615F4FC.74D9EC7D-ON65257688.003074DE-65257688.0038A471@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323329-1660665738-1260441729=:7024
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Thu, 10 Dec 2009, Krishna Kumar2 wrote:

> Hi Ilpo,
> 
> "Ilpo Järvinen" <ilpo.jarvinen@helsinki.fi> wrote on 12/10/2009 01:47:30
> PM:
> 
> > Subject: Re: [PATCH 3/3] tcp: Slightly optimize tcp_sendmsg>
> >
> > > Slightly optimize tcp_sendmsg since NETIF_F_SG is used many
> > > times iteratively in the loop. The only other modification is
> > > to change:
> > >          } else if (i == MAX_SKB_FRAGS ||
> > >                (!i &&
> > >                !(sk->sk_route_caps & NETIF_F_SG))) {
> > >    to:
> > >          } else if (i == MAX_SKB_FRAGS || !sg) {
> >
> > I can see that you make this change from the patch itself but could you
> > give a justification on why dropping the !i is possible? ...I couldn't
> > see what would allow that.
> 
> From what *I understood*, this code (other than the MAX_SKB_FRAGS case)
> executes only due to the else part of "if (skb_tailroom(skb) > 0) {" -
> there was no space in the skb to put the data inline. Hence SG is false
> is a sufficient condition and there is no way to add a fragment (i == 0
> since skb_fill_page_desc cannot be called when !SG).

Please put this description into the patch description then :-). ...After 
some more thinking, reading and verification it seems right, however, it 
certainly wassn't immediately obvious from the code.

...You can add my Acked-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi> for 
the resubmission.

-- 
 i.
--8323329-1660665738-1260441729=:7024--
