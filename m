From: =?ISO-8859-1?Q?David_T=E4ht?= <dave.taht@gmail.com>
Subject: Re: Asserting ECN from userspace?
Date: Thu, 13 Oct 2011 14:44:48 +0200
Message-ID: <4E96DD40.4040002@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040102020901030403060702"
To: bloat <bloat@lists.bufferbloat.net>, netdev@vger.kernel.org,
	Juliusz Chroboczek <jch@pps.jussieu.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:60752 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754207Ab1JMMov (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2011 08:44:51 -0400
Received: by wwf22 with SMTP id 22so1686421wwf.1
        for <netdev@vger.kernel.org>; Thu, 13 Oct 2011 05:44:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------040102020901030403060702
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit


My original attempt at sending this was blocked due to the ip address
embedded in the url I'd included.... resending...

On 10/13/2011 01:30 PM, Juliusz Chroboczek wrote:
> Dave,
>
> I'm not sure what you are getting at.  ECN is designed for routers, not
> for end-points.

Which happens to be what I'm primarily working on at the moment.
Secondly, in mesh networks, all machines are routers.

>   Assering ECN congestion-experienced at the sender will
> cause the sender to react to the congestion indication after a whole RTT
> (after the ECN-echo is received).  For end-to-end flow control, it is
> both simpler and more efficient to reduce the sending rate immediately,
> without going over the network.
>
> There's a good reason why we're careful to distinguish congestion
> control (router-to-endpoint) and flow control (endpoint-to-endpoint).
> The latter is much easier.
My message was overly broad in scope and I failed to distinguish between 'asserting ECN from userspace', and 'indicating a flow was ECN capable'


>> 1) Applications such as bittorrent (transmission, etc) that are much
>> more aware of their overall environment could assert ECN on their UDP
>> streams to indicate congestion.
> The sender can react to congestion by simply reducing the sending rate.
> The receiver can react to congestion by pipelining fewer chunk requests
> to the sender.
>

And what I meant here, was more 'indicate a flow is ecn capable' than
'assert ECN', so routers in the middle can do better signalling.

...although I can still imagine circumstances where asserting ECN makes
sense at the endpoint. See for example:

http://en.wikipedia.org/wiki/Data_Center_TCP

>> 3) Web Proxies. A web proxy could note when it was experiencing
>> congestion on one side of the proxied connection (or another) and signal
>> the other side to slow down.
> It can cause the other side to slow down by simply stopping reading,
> thus causing the normal TCP flow control (not congestion control) to
> kick in.

Yes, but in this case a TCP flow will continue to scale the window and
thus sending rate until those buffers fill. Signalling ECN sooner would
allow a middlebox/web proxy/split tcp session that is blocking on send
to throttle the overall rate from the other side at the speed it is
actually capable of retransmitting.

> What would be useful, on the other hand, would be the ability to set the
> ECN enabled codepoint on UDP packets, 

Agreed.

> and have some means to reliably
> check whether the Congestion-Experienced codepoint has been set by some
> intermediate router. 
>From the previous discussion on this thread it looks as though the core
capabilities exist, if not application code... which looks simple to
play with, and then apply to the AQM work ongoing.

>  But that's different from what you appear to be
> suggesting.
>

You make my thoughts clearer, as always.

Also, as we discussed elsewhere, setting the ECN capable bit on streams
such as VOIP has a packet
preservation-through-a-single-congested-endpoint feature that may well
be useful.

Completely as a side note, I've been looking over the shortest queue
first algorithm for AQM, which is quite promising in and of itself,
without qos or signalling needed at all.

My first attempt at sending this mail failed due to the embedded ip
address for the paper in the google search - if you search for this, you
can find the paper I'm referring to:

  Self-Prioritization of Audio and Video Traffic

> -- Juliusz


-- 
Dave Täht


--------------040102020901030403060702
Content-Type: text/x-vcard; charset=utf-8;
 name="dave_taht.vcf"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="dave_taht.vcf"

begin:vcard
fn;quoted-printable:Dave T=C3=A4ht
n;quoted-printable:T=C3=A4ht;Dave
email;internet:dave.taht@gmail.com
tel;home:1-239-829-5608
tel;cell:0638645374
x-mozilla-html:FALSE
version:2.1
end:vcard


--------------040102020901030403060702--
