From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: two other cases Re: [Bug 11721] after upgrade to 2.6.27 i cannot
 navigate
Date: Wed, 22 Oct 2008 15:09:40 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0810221455010.7072@wrl-59.cs.helsinki.fi>
References: <Pine.LNX.4.64.0810211200170.7072@wrl-59.cs.helsinki.fi>
 <20081021201857.08faf0a7@topolino> <20081021184539.GA3320@ami.dom.local>
 <20081021.163207.157978465.davem@davemloft.net>
 <Pine.LNX.4.64.0810221244390.7072@wrl-59.cs.helsinki.fi> <20081022134939.64f2b6b4@topolino>
Mime-Version: 1.0
Content-Type: MULTIPART/Mixed; boundary="MP_/GTzZ.eRsHe+eGBoELqHOOey"
Cc: David Miller <davem@davemloft.net>, jarkao2@gmail.com,
	Netdev <netdev@vger.kernel.org>,
	bugme-daemon@bugzilla.kernel.org, olon@verizon.net
To: Aldo Maggi <sentiniate@tiscali.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:42987 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751326AbYJVMKo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2008 08:10:44 -0400
In-Reply-To: <20081022134939.64f2b6b4@topolino>
Content-ID: <Pine.LNX.4.64.0810221455011.7072@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--MP_/GTzZ.eRsHe+eGBoELqHOOey
Content-Type: TEXT/PLAIN; charset=utf-8
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0810221455012.7072@wrl-59.cs.helsinki.fi>
Content-Disposition: inline

On Wed, 22 Oct 2008, Aldo Maggi wrote:

> Il giorno Wed, 22 Oct 2008 13:00:01 +0300 (EEST)
> "Ilpo Järvinen" <ilpo.jarvinen@helsinki.fi> ha scritto:
> 
> [...]
> 
> > 
> > It would be nice for Aldo to check what the result will be with my
> > second patch (only) using sack=1,ts=0,wscale=0. I guess it does but
> > it's a bit unclear if nop's in front help or not (having the patch
> > below should anyway help also in that case as the mss option gets
> > moved before it anyway).
> 
> in order to avoid misunderstandings, i list herebelow my actions:
> 
> i've used on paperino the kernel 2.6.27.2 patched with ilpo's
> 21.10.2008 patch (see please comment 47 in
> http://bugzilla.kernel.org/show_bug.cgi?id=11721, and NOT with the patch
> contained in comment 58, right?)

Yes, you understood me correctly. This was more or less for completeleness 
test only, to see if the nop's make any difference or not. You found out 
that they do which seemed the more sensible alternative anyway.

> i've modified the following files:
> echo 0 > /proc/sys/net/ipv4/tcp_window_scaling
> echo 0 > /proc/sys/net/ipv4/tcp_timestamps
> echo 1 > /proc/sys/net/ipv4/tcp_sack
> 
> the results are that i CAN navigate (w3m kernel.org) and update my
> system (apt-get update in debian).
>
> should it be of any help to ilpo, i attach the usual tcpdump on the wan
> eth of topolino (my home server/gw)

...It confirms that you made the right test. :-)

So only thing that was problem in your case is that sackOK option (or 
SACK_PERM in code notation) couldn't begin TCP options. With any other 
option as the first one, including nop, it does work. Thanks for all the 
testing you made and reporting it in the first place.

We'll put the latest patch (from comment #58) and it soon makes to 
2.6.28-rcsomething and hopefully with a semi-short delay to some
2.6.27.y, whichever y is appropriate at that time. I hope that the
ubuntu kernel people will then include that as well but it's beoynd
my control what they do.

Thanks again.

-- 
 i.
--MP_/GTzZ.eRsHe+eGBoELqHOOey--
