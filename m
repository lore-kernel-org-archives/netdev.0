From: Linus =?utf-8?Q?L=C3=BCssing?= <linus.luessing@c0d3.blue>
Subject: Re: bride: IPv6 multicast snooping enhancements
Date: Tue, 10 Feb 2015 12:44:28 +0100
Message-ID: <20150210114428.GK2489@odroid>
References: <1378253619-23918-1-git-send-email-linus.luessing@web.de>
	<54D9C4ED.6040601@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, Cong Wang <amwang@redhat.com>
To: Vasily Averin <vvs@parallels.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <54D9C4ED.6040601@parallels.com>
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

Hi Vasily,

On Tue, Feb 10, 2015 at 11:44:29AM +0300, Vasily Averin wrote:
> This patch prevent forwarding of ICMPv6 in bridges,
> so containers/VMs with virtual eth adapters connected in local bridge cannot ping each other via ipv6 (but can do it via ipv4)

If a host wants to receive packets, then it needs to signalize
that via MLD. If your host does not do that, then it is expected
to not receive ICMPv6 echo requests to multicast addresses. An
exception is ff02::1, that should always work.

> 
> Could you please clarify, is it expected behavior?
> Do we need to enable multicast routing or multicast_snooping on all local ports on such bridges to enable just ICMPv6?

Nope, you shouldn't. You'd need multicast listeners. You shouldn't
need to play with the bridge settings to fix protocols.

> I believe ICMPv6 is an exception and should not be filtered by multicast spoofing.

Signaling multicast joins is mandatory by the IPv6 standard. If
your protocol/application does not do that, then it seems to me
that the application might be broken.


By the way, which kernel version(s) are you using?

Cheers, Linus
