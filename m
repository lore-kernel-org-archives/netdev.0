From: Or Gerlitz <ogerlitz@Voltaire.com>
Subject: Re: [Qemu-devel] [PATCH] net: add raw backend  - some performance
 measurements
Date: Tue, 21 Jul 2009 16:41:38 +0300
Message-ID: <4A65C592.4060103@Voltaire.com>
References: <20090707145739.GB14392@shareable.org>	<4A54B0F1.3070201@voltaire.com> <20090715203806.GF3056@shareable.org>	<4A647B72.5090404@Voltaire.com> <20090720155308.GA9327@gondor.apana.org.au>	<4A656824.7070100@Voltaire.com> <20090721072546.GA16131@gondor.apana.org.au>	<20090721102733.GB22155@redhat.com> <4A65A0FC.6090204@Voltaire.com>	<20090721120142.GA23439@redhat.com> <20090721121420.GA19236@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Jamie Lokier <jamie@shareable.org>,
	Anthony Liguori <anthony@codemonkey.ws>, qemu-devel@nongnu.org,
	Jan Kiszka <jan.kiszka@web.de>,
	Mark McLoughlin <markmc@redhat.com>,
	Dor Laor <dlaor@redhat.com>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fwil.voltaire.com ([193.47.165.2]:31217 "EHLO exil.voltaire.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754524AbZGUNlr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Jul 2009 09:41:47 -0400
In-Reply-To: <20090721121420.GA19236@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Tue, Jul 21, 2009 at 03:01:42PM +0300, Michael S. Tsirkin wrote:

>> the thing to check then would be that some kind of misconfiguration
>> does not cause the bridge to flood your packets to multiple interfaces.

> Right, we should make sure that the interfaces are not in promiscous mode

Michael, Herbert, 

First, I don't see how flooding can happen in my setup, I have only two interfaces on 
the bridge (see below), a tap and a NIC (vlan) and the bridge will never attempt to forward
a packet through the port it was received. Second, the bridge always set all interfaces
attached to it to be in promiscous mode, see the call to dev_set_promiscuity() from br_add_if()
but this doesn't mean it applied flooding, it does mac learning...

Or.

# brctl show
bridge name     bridge id               STP enabled     interfaces
br0             8000.0030485f9977       no              eth1.4009
                                                        tap0

The VM mac is de:ab:be:01:01:09 and the remote node mac is 00:30:48:65:a6:2b, you 
can see that these two macs were learned by the bridge and hence no flooding is expected.

# brctl showmacs br0
port no mac addr                is local?       ageing timer
  1     00:30:48:5f:99:77       yes                0.00
  1     00:30:48:65:a6:2b       no                12.50
  2     06:f5:76:64:a0:d4       yes                0.00
  2     de:ab:be:01:01:09       no                 0.00
