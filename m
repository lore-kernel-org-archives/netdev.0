From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [net-next PATCH v3 00/17] Future-proof tunnel offload handlers
Date: Tue, 21 Jun 2016 10:05:08 -0700
Message-ID: <CAKgT0Ucze-+PYdvoHhDSLuaTLrn+Ene+CnfJaKO7AEHGHBsKzg@mail.gmail.com>
References: <20160616191851.20872.67154.stgit@localhost.localdomain>
 <20160617.202641.1821023739498595024.davem@davemloft.net> <CALx6S34Y3Qq6nMHuMcC2LC5duLBO3KVN3+A+0qmPrNvFfY7gJg@mail.gmail.com>
 <20160621.042211.945844554759834352.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Tom Herbert <tom@herbertland.com>,
	Alex Duyck <aduyck@mirantis.com>,
	Netdev <netdev@vger.kernel.org>,
	intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
	Hannes Frederic Sowa <hannes@redhat.com>,
	Jesse Gross <jesse@kernel.org>,
	Eugenia Emantayev <eugenia@mellanox.com>,
	Jiri Benc <jbenc@redhat.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Ariel Elior <ariel.elior@qlogic.com>,
	Michael Chan <michael.chan@broadcom.com>,
	Dept-GELinuxNICDev@qlogic.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f173.google.com ([209.85.223.173]:34591 "EHLO
	mail-io0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752488AbcFURFK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2016 13:05:10 -0400
Received: by mail-io0-f173.google.com with SMTP id g13so15170022ioj.1
        for <netdev@vger.kernel.org>; Tue, 21 Jun 2016 10:05:10 -0700 (PDT)
In-Reply-To: <20160621.042211.945844554759834352.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 21, 2016 at 1:22 AM, David Miller <davem@davemloft.net> wrote:
> From: Tom Herbert <tom@herbertland.com>
> Date: Mon, 20 Jun 2016 10:05:01 -0700
>
>> Generally, this means it needs to at least match by local addresses
>> and port for an unconnected/unbound socket, the source address for
>> an unconnected/bound socket, a the full 4-tuple for a connected
>> socket.
>
> These lookup keys are all insufficient.
>
> At the very least the network namespace must be in the lookup key as
> well if you want to match "sockets".  And this is just the tip of the
> iceberg in my opinion.
>
> The namespace bypassing to me is the biggest flaw in the UDP tunnel
> offloads.  That is creating real dangers right now.

I agree.  Fortunately this only really becomes an issue if SR-IOV is
enabled.  Otherwise the port based offloads only affect the PF as long
as no VFs are present.

> But anyways, the vastness of the key is why we want to keep "sockets"
> out of network cards, because proper support of "sockets" requires
> access to information the card simply does not and should not have.

Right.  Really what I would like to see for most of these devices is a
2 tuple filter where you specify the UDP port number, and the PF/VF ID
that the traffic is received on.  In order to get that we wouldn't
need any additional information from the API.  Then we at least have
indirect namespace isolation, and if someone really wanted to they
could do offloads on the VFs for different traffic.
