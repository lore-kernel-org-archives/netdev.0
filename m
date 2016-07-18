From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH v2 net-next v2 12/12] net: dsa: mv88e6xxx: add support for DSA ageing time
Date: Mon, 18 Jul 2016 15:26:42 -0400
Message-ID: <87d1malpcd.fsf@ketchup.mtl.sfl>
References: <20160718184628.13103-1-vivien.didelot@savoirfairelinux.com> <20160718184628.13103-13-vivien.didelot@savoirfairelinux.com> <20160718191644.GG31103@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160718191644.GG31103@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

> This is way too simplistic.
>
> The switchdev call is per port. This manipulates the whole switch. We
> need to somehow handle the difference.
>
> I've not look at the bridge code, but i assume it initially sets each
> port to a long age time, probably 5 minutes. When there is a topology
> change, it enables fast ageing by setting a shorter age time in each
> port. After a while it will return to the default age time. Although
> the switchdev call is per port, i think the age time is a property of
> the bridge, not a port.
>
> For the Marvell devices, we only have a global setting. It will apply
> to all bridges we create on the switch. So if one bridge requests fast
> ageing, we need to apply it to all bridges. We should only go back to
> slow ageing when all bridges are out of fast ageing. That is, we need
> some sort of reference counting.
>
> I'm not sure we have enough information to know why the bridge changed
> the age timing. Did the use change the forwarding delay, or have we
> entered fast ageing? So i think for Marvell devices, we need an
> additional property passed down. Is this a fast or a slow age time?
> We can then determine what is the fastest fast ageing, and the fastest
> slow ageing is, perform reference counting as appropriate, and set the
> global setting as needed.

Nope, the bridge ageing time is not per-port, even though switchdev ops
are per-port by design. This is a switch-wide attribute.

See f55ac58ae64c ("switchdev: add bridge ageing_time attribute") [1]

Rocker and mlxsw implement AGEING_TIME switch-wide too.

[1] https://git.kernel.org/cgit/linux/kernel/git/davem/net.git/commit/?id=f55ac58ae64c

Thanks,

        Vivien
