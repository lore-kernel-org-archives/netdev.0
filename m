From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv3] net: fix bridge multicast packet checksum
	validation
Date: Thu, 25 Feb 2016 16:19:39 -0500 (EST)
Message-ID: <20160225.161939.1019283825389790873.davem@davemloft.net>
References: <1456284102-32557-1-git-send-email-linus.luessing@c0d3.blue>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, sgunderson@bigfoot.com, tom@herbertland.com
To: linus.luessing@c0d3.blue
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1456284102-32557-1-git-send-email-linus.luessing@c0d3.blue>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

From: Linus L=FCssing <linus.luessing@c0d3.blue>
Date: Wed, 24 Feb 2016 04:21:42 +0100

> We need to update the skb->csum after pulling the skb, otherwise
> an unnecessary checksum (re)computation can ocure for IGMP/MLD packet=
s
> in the bridge code. Additionally this fixes the following splats for
> network devices / bridge ports with support for and enabled RX checks=
um
> offloading:
> =

> [...]
> [   43.986968] eth0: hw csum failure
> [   43.990344] CPU: 3 PID: 0 Comm: swapper/3 Not tainted 4.4.0 #2
> [   43.996193] Hardware name: BCM2709
> [   43.999647] [<800204e0>] (unwind_backtrace) from [<8001cf14>] (sho=
w_stack+0x10/0x14)
> [   44.007432] [<8001cf14>] (show_stack) from [<801ab614>] (dump_stac=
k+0x80/0x90)
> [   44.014695] [<801ab614>] (dump_stack) from [<802e4548>] (__skb_che=
cksum_complete+0x6c/0xac)
> [   44.023090] [<802e4548>] (__skb_checksum_complete) from [<803a055c=
>] (ipv6_mc_validate_checksum+0x104/0x178)
> [   44.032959] [<803a055c>] (ipv6_mc_validate_checksum) from [<802e11=
1c>] (skb_checksum_trimmed+0x130/0x188)
> [   44.042565] [<802e111c>] (skb_checksum_trimmed) from [<803a06e8>] =
(ipv6_mc_check_mld+0x118/0x338)
> [   44.051501] [<803a06e8>] (ipv6_mc_check_mld) from [<803b2c98>] (br=
_multicast_rcv+0x5dc/0xd00)
> [   44.060077] [<803b2c98>] (br_multicast_rcv) from [<803aa510>] (br_=
handle_frame_finish+0xac/0x51c)
> [...]
> =

> Fixes: 9afd85c9e455 ("net: Export IGMP/MLD message validation code")
> Reported-by: =C1lvaro Fern=E1ndez Rojas <noltari@gmail.com>
> Signed-off-by: Linus L=FCssing <linus.luessing@c0d3.blue>

Applied and queued up for -stable, thanks!
