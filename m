From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: What was the reason for 2.6.22 SMP kernels to change how sendmsg is called?
Date: Fri, 14 Dec 2007 09:33:24 +0300
Message-ID: <20071214063324.GC26171@2ka.mipt.ru>
References: <20071213.131753.156591181.davem@davemloft.net> <B1F576FE19C55C43B8D2E31F061B50C04E60B2@exchange.comtrol.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Kevin Wilson <Kevin.Wilson@comtrol.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:46580 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750708AbXLNGdn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Dec 2007 01:33:43 -0500
Content-Disposition: inline
In-Reply-To: <B1F576FE19C55C43B8D2E31F061B50C04E60B2@exchange.comtrol.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Kevin.

On Thu, Dec 13, 2007 at 04:00:02PM -0600, Kevin Wilson (Kevin.Wilson@comtrol.com) wrote:
> I see your point but it just so happens it is a GPL'd driver, as is all of our Linux code we produce for our hardware. Granted it is out of tree, and after you saw it you would want it to stay that way. However, I would have sent you the whole thing if that is a pre-req to cordial exchanges on this list.
> 
> Nonetheless, a somewhat recent change in your tree, that I could not pinpoint on my own, caused the driver to stop functioning properly. So after much searching in git/google/sources with no luck, I decided to ask for a little assistance, maybe just a hint as to where the culprit may be in the tree so I could investigate for myself. For SNGs I tried the method that now works but I am still at a loss as to (can't find) what changes in the tree caused it to fail.

Without having your code it is virtually impossible to say, why you have
a bug. And do not express your frustration telling 'zero people
responded to my bug report'. This was not a bug report at all, but empty
message about 'my code stopped working after some network changes, which
broke the stuff.

>Now in 2.6.22 and later kernels you must use the higher level SOCKET to
>make a call to PROTO_OPS then to sendmsg(). e.g., socket->ops->sendmsg().

It was done because of bug found in inet_sendmsg(), which tried to
autobind socket it should not try.

-- 
	Evgeniy Polyakov
