From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v2 1/2] net: Added mtu parameter to dev_forward_skb
 calls
Date: Thu, 11 May 2017 09:01:32 -0700
Message-ID: <20170511090132.79fdbf12@xeon-e3>
References: <20170511134629.139528-1-fredrik.markstrom@gmail.com>
        <20170511134629.139528-2-fredrik.markstrom@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, bridge@lists.linux-foundation.org
To: Fredrik Markstrom <fredrik.markstrom@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170511134629.139528-2-fredrik.markstrom@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 11 May 2017 15:46:27 +0200
Fredrik Markstrom <fredrik.markstrom@gmail.com> wrote:

> From: Fredrik Markstr=C3=B6m <fredrik.markstrom@gmail.com>
>=20
> is_skb_forwardable() currently checks if the packet size is <=3D mtu of
> the receiving interface. This is not consistent with most of the hardware
> ethernet drivers that happily receives packets larger then MTU.

Wrong.

Hardware interfaces are free to drop any packet greater than MTU (actually =
MTU + VLAN).
The actual limit is a function of the hardware. Some hardware can only limi=
t by
power of 2; some can only limit frames larger than 1500; some have no limit=
ing at all.
Any application that should:
  * not expect packets larger than MTU to be received
  * not send packets larger than MTU
  * check actual receive size. IP protocols will do truncation of padded pa=
ckets
