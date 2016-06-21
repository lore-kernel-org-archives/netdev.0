From: Edward Cree <ecree@solarflare.com>
Subject: Re: [net-next PATCH v3 00/17] Future-proof tunnel offload handlers
Date: Tue, 21 Jun 2016 18:27:00 +0100
Message-ID: <18b4d172-2cf5-8246-9cac-ce92adf65bc8@solarflare.com>
References: <20160616191851.20872.67154.stgit@localhost.localdomain>
 <20160617.202641.1821023739498595024.davem@davemloft.net>
 <CALx6S34Y3Qq6nMHuMcC2LC5duLBO3KVN3+A+0qmPrNvFfY7gJg@mail.gmail.com>
 <20160621.042211.945844554759834352.davem@davemloft.net>
 <CAKgT0Ucze-+PYdvoHhDSLuaTLrn+Ene+CnfJaKO7AEHGHBsKzg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom@herbertland.com>,
	Alex Duyck <aduyck@mirantis.com>,
	Netdev <netdev@vger.kernel.org>,
	intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
	Hannes Frederic Sowa <hannes@redhat.com>,
	Jesse Gross <jesse@kernel.org>,
	Eugenia Emantayev <eugenia@mellanox.com>,
	Jiri Benc <jbenc@redhat.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	"Ariel Elior" <ariel.elior@qlogic.com>,
	Michael Chan <michael.chan@broadcom.com>,
	<Dept-GELinuxNICDev@qlogic.com>
To: Alexander Duyck <alexander.duyck@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo04.seg.att.com ([209.65.160.86]:44372 "EHLO
	nbfkord-smmo04.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752871AbcFURdo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2016 13:33:44 -0400
In-Reply-To: <CAKgT0Ucze-+PYdvoHhDSLuaTLrn+Ene+CnfJaKO7AEHGHBsKzg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 21/06/16 18:05, Alexander Duyck wrote:
> On Tue, Jun 21, 2016 at 1:22 AM, David Miller <davem@davemloft.net> wrote:
>> But anyways, the vastness of the key is why we want to keep "sockets"
>> out of network cards, because proper support of "sockets" requires
>> access to information the card simply does not and should not have.
> Right.  Really what I would like to see for most of these devices is a
> 2 tuple filter where you specify the UDP port number, and the PF/VF ID
> that the traffic is received on.
But that doesn't make sense - the traffic is received on a physical network
port, and it's the headers (i.e. flow) at that point that determine whether
the traffic is encap or not.  After all, those headers are all that can
determine which PF or VF it's sent to; and if it's multicast and goes to
more than one of them, it seems odd for one to treat it as encap and the
other to treat it as normal UDP - one of them must be misinterpreting it
(unless the UDP is going to a userspace tunnel endpoint, but I'm ignoring
that complication for now).
At a given physical point in the network, a given UDP flow either is or is
not carrying encapsulated traffic, and if it tries to be both then things
are certain to break, just as much as if two different applications try to
use the same UDP flow for two different application protocols.

-Ed
