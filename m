From: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Subject: Re: [patches] a bunch of old bluetooth fixes
Date: Fri, 19 Dec 2014 13:57:35 +0100
Message-ID: <015D7FD4-F115-4046-8016-D155912D8FEF@holtmann.org>
References: <20141219061801.GU22149@ZenIV.linux.org.uk> <B0609FEE-1CE5-4618-A0B6-B2B82B1EC74D@holtmann.org>
Mime-Version: 1.0 (Mac OS X Mail 8.1 \(1993\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	BlueZ development <linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <B0609FEE-1CE5-4618-A0B6-B2B82B1EC74D-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

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

never mind that. We have another bug in 6LoWPAN with wrongly freeing a skb. I took all 3 of Al's patches now and I will ask Johan to send you a pull request for the whole set for net tree inclusion.

Regards

Marcel
