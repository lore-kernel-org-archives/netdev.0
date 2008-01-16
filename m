From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Packetlost when "tc qdisc del dev eth0 root"
Date: Wed, 16 Jan 2008 09:02:59 +0100
Message-ID: <20080116080259.GB1638@ff.dom.local>
References: <478C94B7.3070503@bigtelecom.ru> <478CD9D6.3000504@trash.net> <478D226E.1050209@gmail.com> <478D8FC8.9000107@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Badalian Vyacheslav <slavon@bigtelecom.ru>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.157]:25950 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752753AbYAPH4i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jan 2008 02:56:38 -0500
Received: by fg-out-1718.google.com with SMTP id e21so179853fga.17
        for <netdev@vger.kernel.org>; Tue, 15 Jan 2008 23:56:37 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <478D8FC8.9000107@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 16, 2008 at 06:02:00AM +0100, Patrick McHardy wrote:
...
> This would need support from the qdiscs to do it properly. Looks
> non-trivial for HTB/HFSC/CBQ, but the others shouldn't be that hard.

Yes. At first I've thought this would need quite a lot of work, but
it seems, there could be probably used something very simple too,
like e.g. a 'dummy' sched switcher, which after replacing as a root
the old qdisc and knowing the pointer to the new one could simply
call for dequeing the old one and the new one for everything else.
Then, after completely dequeuing it would call destroy for the old
qdisc and probably switch itself with the new one as a root. If this
new one were created temporarily e.g. on a dummyX dev, and the switch
qdisc added to dummyY (as a temporary holder) with ethX and dummyX as
parameters, it seems this could be done without any API changes.
(But, of course, something more sophisticated should be even better.)

Regards,
Jarek P.
