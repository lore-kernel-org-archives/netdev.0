From: Stephane Chazelas <stephane.chazelas@gmail.com>
Subject: Re: newline characters in unix socket names and /proc/net/unix
Date: Tue, 17 Mar 2015 21:27:27 +0000
Message-ID: <20150317212727.GB9874@chaz.gmail.com>
References: <20150314223342.GA4146@chaz.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Craig Small <csmall@debian.org>,
	Vic Abell <vabell@lsof.comcastbiz.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:38794 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752997AbbCQV1a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2015 17:27:30 -0400
Received: by wifj2 with SMTP id j2so22300736wif.1
        for <netdev@vger.kernel.org>; Tue, 17 Mar 2015 14:27:29 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20150314223342.GA4146@chaz.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2015-03-14 22:33:42 +0000, Stephane Chazelas:
[...]
> it seems the kernel doesn't escape newline characters in the
> file names displayed in /proc/net/unix
[...]
> and is used by things like fuser, lsof for instance to map Inode
> to Path (and libgtop, systemd (to check which sockets are still
> in use for cleanup) at least).
[...]

A solution for fuser and lsof (at least) would be to use the new
netlink-based API where available (like "ss -ax" does on recent
systems) that doesn't have the problem.

For lsof, that would also mean (for linux-3.3 and above) that it
could display information about the peer of the socket (like it
does with lsof -E for pipes).

-- 
Stephane
