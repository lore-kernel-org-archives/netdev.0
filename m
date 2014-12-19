From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [patches] a bunch of old bluetooth fixes
Date: Fri, 19 Dec 2014 11:30:38 +0100
Message-ID: <07BDA2A2-1560-4F78-A0B2-FC25E312CACE@holtmann.org>
References: <20141219061801.GU22149@ZenIV.linux.org.uk> <B0609FEE-1CE5-4618-A0B6-B2B82B1EC74D@holtmann.org>
Mime-Version: 1.0 (Mac OS X Mail 8.1 \(1993\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Network Development <netdev@vger.kernel.org>,
	BlueZ development <linux-bluetooth@vger.kernel.org>
To: Al Viro <viro@ZenIV.linux.org.uk>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:55875 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751370AbaLSKan convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Dec 2014 05:30:43 -0500
In-Reply-To: <B0609FEE-1CE5-4618-A0B6-B2B82B1EC74D@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

>> 	This stuff has been sitting in my queue since March; basically,
>> several places in net/bluetooth assume that they are dealing with
>> l2cap sockets, while it is possible to get an arbitrary socket to those.
>> Results are not pretty.
>> 	* HIDPCONNADD gets an arbitrary user-supplied socket; the code
>> it calls (hidp_connection_add()) verifies that the socket is l2cap one,
>> but before doing so it finds l2cap_pi(ctrl_sock->sk)->chan.  It's not
>> that big a deal (it's only 5 words past the end of struct sock), but
>> it's trivial to avoid and, in theory, we might end up oopsing here if
>> we are very unlucky and it happens to hit an unmapped page just past
>> the actual object ctrl_sock->sk sits in.
>> 	* CMTP counterpart of that doesn't validate the socket at all.
>> It proceeds to
>>       s = __cmtp_get_session(&l2cap_pi(sock->sk)->chan->dst);
>> which can very easily oops - here ->chan is already garbage and we
>> proceed to dereference that.  As with HIDP, one needs CAP_NET_ADMIN to
>> trigger that, but it's really a clear bug.  The only sanity check we
>> do is verifying that nsock->sk->sk_state is equal to BT_CONNECTED,
>> which is not unique to bluetooth, to put it mildly.  It's just 1,
>> so a TCP_ESTABLISHED tcp socket will pass that check just fune.
>> The fix is trivial...
>> 	* BNEP situation is identical to CMTP one.
>> 
>> I've sent these patches back then (March 10), but they seem to have fallen
>> through the cracks.  The bugs are still there and the fixes still apply.
>> If you would prefer me to resend them after -rc1, just tell...
> 
> they must have really fallen through the cracks since I do not even remember them.
> 
> My take is that these should all go in before -rc1 and preferable also make it into stable. While you need CAP_NET_ADMIN capability, there are clear stupid bugs on our side.
> 
> Dave, we can prepare a pull request for these or do you want to take them directly into net tree?

and in case you decide to take them directly.

Acked-by: Marcel Holtmann <marcel@holtmann.org>

Regards

Marcel
