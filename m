From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: Re : Oops preceded by WARNING: at net/ipv4/tcp_input.c:1571
 tcp_remove_reno_sacks()
Date: Thu, 15 Nov 2007 10:11:26 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0711151000570.7798@kivilampi-30.cs.helsinki.fi>
References: <Pine.LNX.4.64.0711132321340.3997@kivilampi-30.cs.helsinki.fi>
 <20071113.210431.141662500.davem@davemloft.net>
 <Pine.LNX.4.64.0711141245050.23382@kivilampi-30.cs.helsinki.fi>
 <20071114.155551.93961946.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-1869840047-1195114286=:7798"
Cc: guichaz@yahoo.fr, Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:60885 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754630AbXKOIL2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2007 03:11:28 -0500
In-Reply-To: <20071114.155551.93961946.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-1869840047-1195114286=:7798
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Wed, 14 Nov 2007, David Miller wrote:

> From: "Ilpo_Järvinen" <ilpo.jarvinen@helsinki.fi>
> Date: Wed, 14 Nov 2007 15:32:58 +0200 (EET)
> 
> > [PATCH] [TCP] FRTO: Clear frto_highmark only after process_frto that uses it
> > 
> > I broke this in commit 3de96471bd7fb76406e975ef6387abe3a0698149.
> > tcp_process_frto should always see a valid frto_highmark. An
> > invalid frto_highmark (zero) is very likely what ultimately
> > caused a seqno compare in tcp_frto_enter_loss to do the wrong
> > leading to the LOST-bit leak.
> > 
> > Having LOST-bits integry ensured like done after commit
> > 23aeeec365dcf8bc87fae44c533e50d0bb4f23cc won't hurt. It may
> > still be useful in some other, possibly legimate, scenario.
> > 
> > Reported by Chazarain Guillaume <guichaz@yahoo.fr>.
> > 
> > Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
> 
> Applied.
> 
> Thanks for making such an incredibly thorough investigation
> into this bug!

I suppose this bug also caused all those spurious rtos I used to see with 
my home connection (~10% of all RTOs during 10M scp transfer). They seemed 
a bit out of place because it's all wired and low RTT. Though there are bw 
limits enforced by ISP which I first suspected could cause it, except for 
suspecting bug in my code of course :-). ...It seems I can drop 
investigating them now since last evening test run gave 0 spurious
RTOs :-).

Thanks Chazarain for you report.

-- 
 i.
---696243703-1869840047-1195114286=:7798--
