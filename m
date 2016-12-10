From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH/RFC net-next] net: fec: allow "mini jumbo" frames
Date: Sat, 10 Dec 2016 11:55:11 -0500
Message-ID: <87lgvn3es0.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <1481275255-7650-1-git-send-email-nikita.yoush@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Chris Healy <cphealy@gmail.com>,
        Fabio Estevam <fabio.estevam@nxp.com>,
        linux-kernel@vger.kernel.org,
        Nikita Yushchenko <nikita.yoush@cogentembedded.com>
To: Nikita Yushchenko <nikita.yoush@cogentembedded.com>,
        Fugang Duan <fugang.duan@nxp.com>,
        "David S. Miller" <davem@davemloft.net>,
        Troy Kisky <troy.kisky@boundarydevices.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>, Eric Nelson <eric@nelint.com>,
        Philippe Reynes <tremyfr@gmail.com>,
        Johannes Berg <johannes@sipsolutions.net>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1481275255-7650-1-git-send-email-nikita.yoush@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Nikita,

Nikita Yushchenko <nikita.yoush@cogentembedded.com> writes:

> This adds support for MTU slightly larger than default, on modern
> FEC flavours.
>
> Currently FEC driver uses single hardware Rx buffer per frame. On most
> FEC flavours, size of single buffer is limited by 11-bit field, and
> has to be multiple of 64 (in the worst case). Thus maximum usable Rx
> buffer size is 1984 bytes.
>
> Of those:
> - 2 bytes are used for IP header alignment,
> - 14 bytes are used by ethhdr,
> - up to 8 bytes are needed for VLAN and/or DSA tags,
> - 4 bytes are needed for CRC.
>
> Thus maximum MTU possible within current RX architecture is 1956.
>
> This patch allows exactly that. For further increase, Rx architecture
> change is needed.
>
> Use of MTU=1956 gives about 1.5% throughput improvement between two Vybrid
> boards, compared to default MTU=1500.
>
> Signed-off-by: Nikita Yushchenko <nikita.yoush@cogentembedded.com>

For what it's worth, I have tested your patch on my ZII Rev B boards
(see vf610-zii-dev-rev-b.dts) which have a FEC as the master net device
of their DSA trees. They still work as expected.

Tested-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Thanks,

        Vivien
