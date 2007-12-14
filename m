From: "Kevin Wilson" <Kevin.Wilson@comtrol.com>
Subject: RE: What was the reason for 2.6.22 SMP kernels to change how sendmsg is called?
Date: Fri, 14 Dec 2007 11:55:13 -0600
Message-ID: <B1F576FE19C55C43B8D2E31F061B50C04E60B5@exchange.comtrol.com>
References: <20071214063324.GC26171@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: <netdev@vger.kernel.org>
To: "Evgeniy Polyakov" <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.comtrol.com ([204.73.219.163]:23567 "EHLO
	Exchange.comtrol.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756110AbXLNRzP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Dec 2007 12:55:15 -0500
Content-class: urn:content-classes:message
In-Reply-To: <20071214063324.GC26171@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>do not express your frustration ...

wasn't frustration but rather playful sarcasm.

>>This was not a bug report at all...

Wasn't really meant to be a true blue bug report (my bad I guess). Anywho, I know you guys have big fish to fry so I tried to keep it short and to the point. I knew something had changed and I was truly stumped in trying to figure out what it was so I decided to ask for some general guidance. 

>>Without having your code it is virtually impossible to say.

I know this is partly my own fault for not stating so explicitly in my first email. However, as I stated in my second email, I would have been happy to send it to anyone that expressed an interest (even though the issue wasn't interesting in itself) in my post. I just thought, being the experts you are, that having only the small subset of code that is actually involved in the offending call, you'd be able to say "go take a look at commit such-n-such" which you have now done. Thanks a million!

I'm not trying to start a nag war here, I know you guys are busy. Having both (mostly me) made pitiful assumptions I think we have reached an understanding on this (now dead) topic. I'm just starting out in the drivers arena with hopes of being a decent contributor to the kernel ecosystem some day so there will be some growing pains and this thread was one of them.

Thanks for the help and suggestions, I appreciate them immensely.

Kevin

 
-----Original Message-----
From: netdev-owner@vger.kernel.org
[mailto:netdev-owner@vger.kernel.org]On Behalf Of Evgeniy Polyakov
Sent: Friday, December 14, 2007 00:33
To: Kevin Wilson
Cc: David Miller; netdev@vger.kernel.org
Subject: Re: What was the reason for 2.6.22 SMP kernels to change how
sendmsg is called?


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
--
To unsubscribe from this list: send the line "unsubscribe netdev" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
