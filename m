From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: Fix FRTO+NewReno problem
Date: Tue, 13 May 2008 12:42:03 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0805130958001.14510@wrl-59.cs.helsinki.fi>
References: <Pine.LNX.4.64.0805121656440.1888@wrl-59.cs.helsinki.fi>
 <48288EFE.4020708@damtek.com> <Pine.LNX.4.64.0805122143080.14152@wrl-59.cs.helsinki.fi>
 <20080512.154838.163999274.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696208474-319812498-1210662214=:14510"
Cc: damon@damtek.com, Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:49959 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750735AbYEMJmG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2008 05:42:06 -0400
In-Reply-To: <20080512.154838.163999274.davem@davemloft.net>
Content-ID: <Pine.LNX.4.64.0805131238230.15369@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-319812498-1210662214=:14510
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0805131003471.14510@wrl-59.cs.helsinki.fi>

On Mon, 12 May 2008, David Miller wrote:

> From: "Ilpo_Järvinen" <ilpo.jarvinen@helsinki.fi>
> Date: Mon, 12 May 2008 22:12:47 +0300 (EEST)
> 
> > Then one question for DaveM:
> > 
> > What I'm not fully sure of, is do we want this workaround to be a sysctl 
> > or unconditionally enabled which causes potentially up to two unnecessary 
> > retransmissions? With SACK one or both of them will get SACKed before they 
> > get retransmitted (both cases have common scenarios). (I made that 
> > workaround patch for 2.6.24.1, so YMMV if you just plainly try to apply it 
> > to net-2.6).
> 
> I think we will have to handle this behavior, unconditionally, all
> the time.  Don't even add the sysctl.

Yes, that's what I was thinking in the second option.

> If I understand correctly, it is only non-SACK newreno case that can
> get the unnecessary retransmissions, right?  If so, it's not a big
> deal at all.

No, also SACK could get at least one quite easily if TCP has a small 
window, to get two of them with SACK one needs to have a stranger case
unless I missed something. If I just remove that forward transmission LOST 
marking avoidance unconditionally, it fixes that SACKFRTO window of 
failure too which was a pending thing to fix :-).

Btw, the first two fixes (workaround was not included) also fixed bugzilla 
#10063, I just got a confirmation about that as well.

I'll send the two patches still pending separately in a minute.

-- 
 i.
---696208474-319812498-1210662214=:14510--
