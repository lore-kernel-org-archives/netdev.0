From: "J. K. Cliburn" <jcliburn@gmail.com>
Subject: Re: sendfile() broken with 2.6.26 + Apache 2 ?
Date: Sat, 19 Jul 2008 07:31:46 -0500
Message-ID: <4881DEB2.8030508@bellsouth.net>
References: <487CD7A7.2080800@jeffray.co.uk>
Reply-To: jacliburn@bellsouth.net
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Ian Jeffray <ian@jeffray.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.30]:48321 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755598AbYGSMby (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Jul 2008 08:31:54 -0400
Received: by yw-out-2324.google.com with SMTP id 9so230505ywe.1
        for <netdev@vger.kernel.org>; Sat, 19 Jul 2008 05:31:52 -0700 (PDT)
In-Reply-To: <487CD7A7.2080800@jeffray.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ian Jeffray wrote:
> All,
> 
> I moved from kernel 2.6.25.4 to 2.6.26 yesterday and observed that
> large files sent via Apache2 are partially corrupt.
> 
> This appears to be linked to sendfile() -- disabling the use of
> sendfile in the apache config (EnableSendfile Off) allows it to
> function as normal.
> 
> My system is a simple Core2Duo running Debian lenny/sid; nothing
> special, and I have never observed problems like this before.
> 
> The problem feels certainly related to sendfile() since the data
> reads correctly from disc in other programs, and via CIFS etc.
> 
> The corruption happens part-way in to the file... I've no exact
> figure but it would seem like maybe 32KB -- I'm seeing broken
> PNGs served from Apache, where the top few dozen lines decode
> correctly, and the rest is garbage.
> 
> I've made basically no configuration changes between 2.6.25.4 and
> 2.6.26 and have explicitly tried both enabling and disabling the
> new PAT support to no effect.
> 
> This is completely repeatable and reproducible.
> 
> Is anyone else seeing this broken behaviour?

Can you please enable verbose logging

echo 8 > /proc/sys/kernel/printk
ethtool -s eth0 msglvl 0xffff

and see if the driver issues any error messages as the file is transferred?
