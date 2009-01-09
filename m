From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [BUG #12364] Re: HTB - very bad precision? HFSC works fine!
	2.6.28
Date: Fri, 9 Jan 2009 09:48:13 +0000
Message-ID: <20090109094813.GD4605@ff.dom.local>
References: <1935.87.196.72.187.1231371721.squirrel@webmail.decimal.pt> <2321.192.168.1.3.1231423743.squirrel@webmail.decimal.pt> <3226.192.168.1.3.1231435651.squirrel@webmail.decimal.pt> <200901082032.16859.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mysql.jorge@decimal.pt, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: Denys Fedoryschenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.27]:22426 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751423AbZAIJsU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2009 04:48:20 -0500
Received: by ey-out-2122.google.com with SMTP id 22so1108535eye.37
        for <netdev@vger.kernel.org>; Fri, 09 Jan 2009 01:48:18 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <200901082032.16859.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 08, 2009 at 08:32:16PM +0200, Denys Fedoryschenko wrote:
> I disable tso/gso and others. No difference at all. Here is actual output, 
> after running it for 1-2 minutes.
> 
> Cisco
>   30 second output rate 59600000 bits/sec, 32978 packets/sec
> Linux
> 
...
> class htb 1:10 root rate 57000Kbit ceil 57000Kbit burst 72838b cburst 72838b
>  Sent 75203300117 bytes 328680653 pkt (dropped 0, overlimits 0 requeues 0)
>  rate 58008Kbit 32891pps backlog 0b 0p requeues 0

Alas you forgot to add "tc -s qdisc" output, so there could be
something more, but what I can see here doesn't look terribly wrong.
The rate is exceeded less than 2%, so it seems some tweaking is
needed. My proposal is to start with setting lower cburst params for
all classes e.g. half of the current values (if no difference go
lower). If it doesn't help send new stats.

Thanks,
Jarek P.
