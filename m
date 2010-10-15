From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: netlink versus pid namespaces
Date: Fri, 15 Oct 2010 19:19:03 +0400
Message-ID: <20101015151903.GA3487@ms2.inr.ac.ru>
References: <20101015142357.GA29321@basil.fritz.box>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, xemul@openvz.org,
	virtualization@lists.linux-foundation.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:39850 "HELO ms2.inr.ac.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1756252Ab0JOPTL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Oct 2010 11:19:11 -0400
Content-Disposition: inline
In-Reply-To: <20101015142357.GA29321@basil.fritz.box>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

> netlink uses pids (or really tids I hope?) to address sockets
> associated with processes.

Not really. It uses port number which is called "pid" occasionally. Bad name.
Autobind function simply selects tgid of calling process as the first guess.

Actually sockets are addressed by pair (net namespace, port) and
communication is possible only inside net namespace. So, communication
between namespaces is already prohibited.

pid namespaces do not participate in the picture at all.

Alexey
