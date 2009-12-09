From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH] Add sysctl to set the advertised TCP initial receive
	window.
Date: Wed, 9 Dec 2009 10:05:26 -0800
Message-ID: <65634d660912091005w127699f7w176cded946a53acc@mail.gmail.com>
References: <pvm638hum1a.fsf@chavey.mtv.corp.google.com>
	 <87fx7kmg6o.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.45.13]:39248 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756490AbZLISFW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2009 13:05:22 -0500
Received: from kpbe14.cbf.corp.google.com (kpbe14.cbf.corp.google.com [172.25.105.78])
	by smtp-out.google.com with ESMTP id nB9I5SSF016929
	for <netdev@vger.kernel.org>; Wed, 9 Dec 2009 10:05:28 -0800
Received: from fg-out-1718.google.com (fgg19.prod.google.com [10.86.7.19])
	by kpbe14.cbf.corp.google.com with ESMTP id nB9I5Q93014299
	for <netdev@vger.kernel.org>; Wed, 9 Dec 2009 10:05:27 -0800
Received: by fg-out-1718.google.com with SMTP id 19so179691fgg.12
        for <netdev@vger.kernel.org>; Wed, 09 Dec 2009 10:05:26 -0800 (PST)
In-Reply-To: <87fx7kmg6o.fsf@basil.nowhere.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 9, 2009 at 5:26 AM, Andi Kleen <andi@firstfloor.org> wrote:
> chavey@google.com writes:
>
>> Add a sysctl, tcp_init_rcv_wnd, to set the TCP initial receive windo=
w
>> size advertised by passive and active TCP connections.
>> The current Linux TCP implementation limits the advertised TCP initi=
al
>> receive window to the one proscribed by slow start. For short leave
>> TCP connections used for transaction type of traffic (i.e. http
>> requests), bounding the advertised TCP initial receive window result=
s
>> in increased latency to complete the transaction. There exists
>> environments where strict adherence to using the TCP initial receive
>> window used by slow start is un-necessary.
>
> That's not the Internet?
>
>> The tcp_init_rcv_wnd sysctl allows increasing the TCP initial receiv=
e
>> window for all TCP connections or on a per TCP connection, allowing
>> for some of the TCP connection to advertise larger TCP receive windo=
w
>> than the ones bounded by slow start.
>
> Traditionally it was very discouraged to expose such settings to user=
s.
> There's the danger that lots of people will essentially turn off cwnd
> without knowing what they're doing to "make downloads go faster", cau=
sing
> problems in the public network.
>

The dangers to the Internet are not exposed on the receiver side but
more on the sender side and its correct adherence to slow start.  A
large majority of clients on the Internet are currently advertising
initial receive windows much higher than 3*MSS (in many cases 64K or
higher), so the impetus is on server side to do the right thing.

Support for setting initial congestion window is already supported in
the stack, but, as has been pointed out this list, it's pretty useless
without the ability to set a larger initial receive window.  If we can
use larger initial congestion windows on private networks that we know
to be essentially uncongested, this can result in reduced
transactional latency by one or more RTTs.  The performance benefits
should be fairly obvious, but we can provide numbers if necessary.

Thanks,
Tom

> -Andi
>
> --
> ak@linux.intel.com -- Speaking for myself only.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
