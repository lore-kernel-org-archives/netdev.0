From: Patrick McHardy <kaber@trash.net>
Subject: Re: [XFRM] Optimize SA dumping
Date: Mon, 04 Dec 2006 14:39:40 +0100
Message-ID: <4574251C.8000906@trash.net>
References: <1165163610.3517.96.camel@localhost>	 <4574164B.1000505@trash.net> <1165238866.3664.43.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:10160 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S936848AbWLDNgd
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Dec 2006 08:36:33 -0500
To: hadi@cyberus.ca
In-Reply-To: <1165238866.3664.43.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> On Mon, 2006-04-12 at 13:36 +0100, Patrick McHardy wrote:
> 
>>jamal wrote:
>>
>>> 	for (i = 0; i <= xfrm_state_hmask; i++) {
>>> 		hlist_for_each_entry(x, entry, xfrm_state_bydst+i, bydst) {
>>>+			if (count && send_x != last_x) {
>>>+				err = func(send_x, count, data);
>>>+				if (err)
>>>+					goto out;
>>>+				send_x = NULL;
>>>+			}
>>> 			if (!xfrm_id_proto_match(x->id.proto, proto))
>>> 				continue;
>>
>>After you sent send_x and set it to NULL, it will be different from
>>last_x (since that is != NULL) and the NULL pointer will be given
>>to func() when continuing here.
>>
> 
> 
> This one you lost me. Can you give me an example? one or two SAs found?

More than three SAs, so we have:

send_x = last_x = NULL

1. iteration:

send_x = last_x = first policy

2. iteration:

send_x = first policy
last_x = second policy

3. iteration:

dump send_x, set send_x = NULL
continue at continue statement

4. iteration:

We have send_x = NULL and last_x != NULL, so send_x != last_x,
leading to dump(NULL, ...)

> In any case, if i go the done callback approach, I can get rid of all
> this tracking thing ...

I need to read your other mail first before commenting on this :)
