From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] net:Add sysctl_max_skb_frags
Date: Tue, 09 Feb 2016 04:30:55 -0500 (EST)
Message-ID: <20160209.043055.1381002982048946744.davem@davemloft.net>
References: <568F87AC.60405@oracle.com>
	<1454488017-8822-1-git-send-email-hans.westgaard.ry@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, tom@herbertland.com, pablo@netfilter.org,
	edumazet@google.com, fw@strlen.de, jiri@resnulli.us,
	alexander.h.duyck@redhat.com, mhocko@suse.com,
	linus.luessing@c0d3.blue, hannes@stressinduktion.org,
	herbert@gondor.apana.org.au, tj@kernel.org,
	akpm@linux-foundation.org, alexey.kodanev@oracle.com,
	haakon.bugge@oracle.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: hans.westgaard.ry@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1454488017-8822-1-git-send-email-hans.westgaard.ry@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Hans Westgaard Ry <hans.westgaard.ry@oracle.com>
Date: Wed,  3 Feb 2016 09:26:57 +0100

> Devices may have limits on the number of fragments in an skb they sup=
port.
> Current codebase uses a constant as maximum for number of fragments o=
ne
> skb can hold and use.
> When enabling scatter/gather and running traffic with many small mess=
ages
> the codebase uses the maximum number of fragments and may thereby vio=
late
> the max for certain devices.
> The patch introduces a global variable as max number of fragments.
>=20
> Signed-off-by: Hans Westgaard Ry <hans.westgaard.ry@oracle.com>
> Reviewed-by: H=E5kon Bugge <haakon.bugge@oracle.com>

I know some people don't like this patch, but no better solution exists
at this time.

Like others, I'd personally would rather this be a per-device attribute
but that currently would not work at all.

The device that TCP and other elements see when the build packets is
not necessarily the one that is going to send the frame.  Encapsulation
and other structures hide the truely transmitting device.

And we lack a foolproof way to propagate attributes like this through
the stack of devices up to the top.

So for now this is what we have to use, as unfortunate as it may be.

If someone is suitably angry about this state of affairs, I encourage
them to direct that energy at a better long term solution :-)

Applied and queued up for -stable, thanks.
