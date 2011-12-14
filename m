From: Jasper Spaans <spaans@fox-it.com>
Subject: Re: kenel level packet capturing
Date: Wed, 14 Dec 2011 10:34:46 +0100
Message-ID: <4EE86DB6.5050303@fox-it.com>
References: <CAKj1SsOnYsOXjRBKm+=hTnEiesXrC3h0Q-KN2b61nPSQud9wMA@mail.gmail.com> <20111019123733.GA21324@synalogic.ca> <CAKj1SsOra7u21u8Zq9rDLzv_Bhx8sPsah+SHByMYQbVc_j6LQA@mail.gmail.com> <20111213.133629.1213042365300662857.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "raviraj.j1991@gmail.com" <raviraj.j1991@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.fox-it.com ([178.250.144.131]:17087 "EHLO ns2.fox-it.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753919Ab1LNJoS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Dec 2011 04:44:18 -0500
In-Reply-To: <20111213.133629.1213042365300662857.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13/12/11 19:36, David Miller wrote:
> We have decided to use PF_RING(a kernel module to capture packets) for
> the same due to the number of advantages.
> What "advantages"?  The AF_PACKET socket layer already upstream in the
> kernel supports every relevant performance feature PF_RING does, and
> then some.
Some documentation for fanout is one feature that would be nice. (How to
use it from userspace - after 5 minutes of googling, the first place
where I could find an example is in the suricata source code[1]).

Having not tested it in practice, so my assumptions about rxhash might
be untrue: is there an option to override the NIC rxhash
implementations? if you are doing packet capturing, you will probably
see traffic in both directions, so hashing on the address-tuples of both
directions makes sense (or else both half-streams of tcp packets might
end up being sent to different sockets.

It seems hardware vendors are focussed on only hashing the senders
address, which does make sense if you're building a
fileserver/webserver/whatever.

We ended up using atrocious bpfs like "((tcp[0:2] & 1) == (tcp[2:2] &
1)) and tcp" to distribute packets over multiple sockets, and now our
bottleneck has shifted away from the capturing side of our application.

(Note to Raviraj: we're not using PF_RING because of stability issues -
it crashed our testing system one too many times.)

Cheers,
Jasper

[1]
https://redmine.openinfosecfoundation.org/embedded/suricata/source-af-packet_8c-source.html#l00516

-- 
 /\____/\   Ir. Jasper Spaans      
 \   (_)/   Fox-IT Experts in IT Security!
  \    X    T: +31-15-2847999
   \  / \   M: +31-6-41588725   
    \/      KvK Haaglanden 27301624
