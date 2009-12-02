From: Andreas Henriksson <andreas@fatal.se>
Subject: Re: [PATCH 2/3] Add new (iptables 1.4.5 compatible) tc/ipt/xt
 module.
Date: Wed, 02 Dec 2009 18:12:49 +0100
Message-ID: <1259773969.9431.41.camel@amd64.fatal.se>
References: <cover.1259765732.git.andreas@fatal.se>
	 <59840ae567f82d81e66367eddea56553e0771e5f.1259765732.git.andreas@fatal.se>
	 <20091202085841.1c37f49f@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from proxy2.bredband.net ([195.54.101.72]:64763 "EHLO
	proxy2.bredband.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755092AbZLBRMS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2009 12:12:18 -0500
Received: from ipb1.telenor.se (195.54.127.164) by proxy2.bredband.net (7.3.140.3)
        id 4AD3E1BC01695010 for netdev@vger.kernel.org; Wed, 2 Dec 2009 18:12:23 +0100
In-Reply-To: <20091202085841.1c37f49f@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On ons, 2009-12-02 at 08:58 -0800, Stephen Hemminger wrote:
> On Wed, 2 Dec 2009 16:11:50 +0100
> Andreas Henriksson <andreas@fatal.se> wrote:
> 
> > Add a new cleaned up m_xt.c based on m_xt_old.c
[..]
> Will this still build on older versions?  The iproute source is supposed
> to build even with really old kernels and older iptables. It has
> maintained source and binary compatibility.
> 

Which of tc/m_ipt.c, tc/m_xt_old.c and tc/m_xt.c will be built depends
on which version of iptables you have installed.
The configure script sets matching flags in Config and tc/Makefile picks
that up and includes the suitable source file.

So tc/m_xt.c will not build with older iptables and it won't be used
with older iptables.

This is not ideal, since if the xtables headers can't be found (ie. the
iptables-dev package isn't installed) the ancient m_ipt.c will be built
and the brokenness won't be detected until the user tries to use the
module.

Distributors will need to watch out for this. It's currently broken in
atleast fedora and debian.

-- 
Regards,
Andreas Henriksson
