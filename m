From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC PATCH 4/5] mlx4: add support for fast rx drop bpf program
Date: Mon, 04 Apr 2016 09:35:10 +0200
Message-ID: <1459755310.18188.13.camel@sipsolutions.net>
References: <1459560118-5582-1-git-send-email-bblanco@plumgrid.com>
	 <1459560118-5582-5-git-send-email-bblanco@plumgrid.com>
	 <1459622455.18188.5.camel@sipsolutions.net>
	 <20160403063834.GE21980@gmail.com> (sfid-20160403_083840_887646_8335D97B)
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org, tom@herbertland.com,
	alexei.starovoitov@gmail.com, ogerlitz@mellanox.com,
	daniel@iogearbox.net, john.fastabend@gmail.com, brouer@redhat.com
To: Brenden Blanco <bblanco@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:44794 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750806AbcDDHfR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Apr 2016 03:35:17 -0400
In-Reply-To: <20160403063834.GE21980@gmail.com> (sfid-20160403_083840_887646_8335D97B)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2016-04-02 at 23:38 -0700, Brenden Blanco wrote:
>=C2=A0
> Having a common check makes sense. The tricky thing is that the type =
can
> only be checked after taking the reference, and I wanted to keep the
> scope of the prog brief in the case of errors. I would have to move t=
he
> bpf_prog_get logic into dev_change_bpf_fd and pass a bpf_prog * into =
the
> ndo instead. Would that API look fine to you?

I can't really comment, I wasn't planning on using the API right now :)

However, what else is there that the driver could possibly do with the
=46D, other than getting the bpf_prog?

> A possible extension of this is just to keep the bpf_prog * in the
> netdev itself and expose a feature flag from the driver rather than
> an ndo. But that would mean another 8 bytes in the netdev.

That also misses the signal to the driver when the program is
set/removed, so I don't think that works. I'd argue it's not really
desirable anyway though since I wouldn't expect a majority of drivers
to start supporting this.

johannes
