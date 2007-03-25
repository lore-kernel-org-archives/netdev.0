From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [RFC PATCHv5 1/5] [TCP]: Add highest_sack seqno, points to
 globally highest SACK
Date: Mon, 26 Mar 2007 00:55:57 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0703260034120.9398@kivilampi-30.cs.helsinki.fi>
References: <11740704663475-git-send-email-ilpo.jarvinen@helsinki.fi>
 <11740704662337-git-send-email-ilpo.jarvinen@helsinki.fi>
 <20070324.210428.78711276.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696243703-140289423-1174858971=:9398"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:49175 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752769AbXCYV4A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Mar 2007 17:56:00 -0400
In-Reply-To: <20070324.210428.78711276.davem@davemloft.net>
Content-ID: <Pine.LNX.4.64.0703260047060.9398@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-140289423-1174858971=:9398
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0703260047061.9398@kivilampi-30.cs.helsinki.fi>

On Sat, 24 Mar 2007, David Miller wrote:

> From: "Ilpo_Järvinen" <ilpo.jarvinen@helsinki.fi>
> Date: Fri, 16 Mar 2007 20:41:02 +0200
> 
> > It is guaranteed to be valid only when !tp->sacked_out. In most
> > cases this seqno is available in the last ACK but there is no
> > guarantee for that. The new fast recovery loss marking algorithm
> > needs this as entry point.
> 
> It's a shame we keep around multiple values which represent very
> related values.  For example, this new seqno could be computed
> using "fackets_out" if we knew also how many holes there were.

It would then be an estimate which is 100% accurate in most cases (when 
all related skbs are full sized). I think it must never underestimate 
highest_sack though, it would be quite ok to use fackets_out * mss but any 
> mss skb would obviously be a problem (if they ever occur)... Are all 
paths ok with that (this is beoynd the codepaths I'm quite sure of...)?!

-- 
 i.
---696243703-140289423-1174858971=:9398--
