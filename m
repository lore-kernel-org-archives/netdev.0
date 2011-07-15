From: Nick Carter <ncarter100@gmail.com>
Subject: Re: [PATCH] bridge: mask forwarding of IEEE 802 local multicast groups
Date: Fri, 15 Jul 2011 16:44:50 +0100
Message-ID: <CAEJpZP1Da=G3--jThbaj5H4+H+836quXXEfGXtBwdPewr-Pjrg@mail.gmail.com>
References: <BANLkTi=jnxBu6WzAOTxHD+e_O1qYKE2m=g@mail.gmail.com>
	<CAEJpZP1cr4B9qX6gH9O4iXwWvEdxs2aebL21FnX1BE0dJPHrEw@mail.gmail.com>
	<20110711082755.0b38a15a@nehalam.ftrdhcpuser.net>
	<20110712113643.GC616804@jupiter.n2.diac24.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org,
	=?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>,
	davem@davemloft.net
To: David Lamparter <equinox@diac24.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:58793 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751125Ab1GOPou convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2011 11:44:50 -0400
Received: by pzk3 with SMTP id 3so1694133pzk.5
        for <netdev@vger.kernel.org>; Fri, 15 Jul 2011 08:44:50 -0700 (PDT)
In-Reply-To: <20110712113643.GC616804@jupiter.n2.diac24.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12 July 2011 12:36, David Lamparter <equinox@diac24.net> wrote:
> On Mon, Jul 11, 2011 at 08:27:55AM -0700, Stephen Hemminger wrote:
>> On Sun, 10 Jul 2011 17:04:30 +0100
>> Nick Carter <ncarter100@gmail.com> wrote:
>>
>> > Updated diffs so they apply to net-next (Original diffs were based=
 off 2.6.38).
>> >
>> > Any chance of getting these diffs applied? =A0The default behaviou=
r of
>> > the bridge code is unchanged. =A0They solve the problem of
>> > authenticating a virtual 802.1x supplicant machine against an exte=
rnal
>> > 802.1X authenticator. =A0It is also a general solution that allows=
 the
>> > forwarding of any combination of the IEEE 802 local multicast grou=
ps.
>> >
>> > Signed-off-by: Nick Carter <ncarter100@gmail.com>
>> > Reviewed-by: David Lamparter <equinox@diac24.net>
>>
>> I am still undecided on this. Understand the need, but don't like id=
ea
>> of bridge behaving in non-conforming manner. Will see if IEEE 802 co=
mmittee
>> has any input.
>
> The patch doesn't make the bridge behave nonconformant. The default m=
ask
> is 0, which just keeps the old behaviour.
Also as David points out in his review, after these diffs are applied
we will be able to remove this
@@ -166,6 +166,9 @@ struct sk_buff *br_handle_frame(struct sk_buff *skb=
)
               if (p->br->stp_enabled =3D=3D BR_NO_STP && dest[5] =3D=3D=
 0)
                       goto forward;
Which is non-standard.

So these diffs enable us to change the existing non-conforming
behaviour to a conforming one.
>
> If you set the lowest 3 bits, yes, you can break your network. But so
> does enabling proxy_arp in most cases. And there are reasonable use
> cases for it, both 802.1X forwarding and fully-transparent* packet
> capture bridges benefit from it. And the latter is something I wouldn=
't
> wish to move to userspace either.
>
> Maybe we should add a warning if the lowest 3 bits are set, like
> "you have enabled forwarding of STP/Pause/Bond frames. This can
> thoroughly break your network."
>
> * excl. pause frames, sadly - those get eaten by hw/driver...
>
>> Also, don't want to build more knobs in with sysfs that are per-brid=
ge.
>> Eventually, the plan is to make all the setting per-port with sysctl=
's
>> like IPv6.
>
> This setting doesn't make sense per-port IMHO. Also, sysctl?!
I agree this setting should be per-bridge.  Also not taking something
that is needed today, because it will make some possible future change
slightly harder, seems a bit conservative to me.
Nick
>
>
> -David
>
>
