From: Olaf Hering <olaf@aepfle.de>
Subject: Re: getting lldp DCB_CMD_IEEE_GET after DCB_CMD_GCAP fails
Date: Fri, 18 Oct 2013 17:40:37 +0200
Message-ID: <20131018154037.GA16687@aepfle.de>
References: <20131015161838.GA10478@aepfle.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.160]:17871 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752830Ab3JRPkk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Oct 2013 11:40:40 -0400
Received: from probook.site
	(dslb-188-106-209-055.pools.arcor-ip.net [188.106.209.55])
	by smtp.strato.de (RZmta 32.9 DYNA|AUTH)
	with (TLSv1.0:DHE-RSA-AES256-SHA encrypted) ESMTPSA id L06fadp9IF4aEq
	for <netdev@vger.kernel.org>; Fri, 18 Oct 2013 17:40:37 +0200 (CEST)
Content-Disposition: inline
In-Reply-To: <20131015161838.GA10478@aepfle.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 15, Olaf Hering wrote:

> Is the code below supposed to work anyway? Thanks for any help.

For some reason libnl does require an ack handler. Without such handler,
if the data and the actual ack are sent back to the application with two
independent messages, the second recv will just be the ack. My example
did not take this into account. Now I changed it to something like this:
 do {
   nl_recvmsgs(handle, cb);
 } while (ack == 0);

Now it happens to work.

Olaf
