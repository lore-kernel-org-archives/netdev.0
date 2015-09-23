From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net 0/2] lwtunnel: make it really work, for IPv4
Date: Wed, 23 Sep 2015 07:17:53 -0500
Message-ID: <87lhbx72j2.fsf@x220.int.ebiederm.org>
References: <cover.1442936392.git.jbenc@redhat.com>
	<87zj0d92ba.fsf@x220.int.ebiederm.org>
	<20150923080957.GB29680@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Jiri Benc <jbenc@redhat.com>, netdev@vger.kernel.org,
	Roopa Prabhu <roopa@cumulusnetworks.com>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:55330 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753068AbbIWMZh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 08:25:37 -0400
In-Reply-To: <20150923080957.GB29680@pox.localdomain> (Thomas Graf's message
	of "Wed, 23 Sep 2015 10:09:57 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thomas Graf <tgraf@suug.ch> writes:

> On 09/22/15 at 11:39pm, Eric W. Biederman wrote:
>> What distinguishes a skb received from a tunnel as opposed to a skb
>> received on from a network device is that a skb recevied on a tunnel
>> has a socket.
>> 
>> I could be easily missing something but couldn't you look at skb->sk
>> on the input path and if a socket is present use the socket to compute
>> the outgoing route?
>> 
>> I expect it would just need to be something like:
>> dst = sk_dst_check(sk, 0);
>
> If you are talking about the UDP socket then that socket would cache
> the underlay route corresponding to the outer header. Jiri is looking
> for the outer header route to derive tunnel parameters from.

Assuming the transport is UDP then it would be a UDP socket.  That
socket will have all of the information needed to construct the outer
header as the receive path of that socket removes the outer header.

I admit you can't use the cached dst.  It is the wrong on that socket.

My point is that if we have the UDP socket and we have the sk we have
all of the information we need to compute the reverse dst.

Having looked a little closer this seems to fall apart in practice as
the tunnel receive path appears to never call skb_set_owner or otherwise
set skb->sk.

Still I am not certain that limitation is fatal.  Looking at the
incoming socket still feels like the right thing to do in this
situation.

Eric
