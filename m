From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: Re: [PATCH] bridge: missing null bridge device check
 causing null pointer dereference (bugfix)
Date: Thu, 06 Nov 2014 17:28:56 +0900
Message-ID: <545B3148.8000704@lab.ntt.co.jp>
References: <1415255192-13584-1-git-send-email-suhyun.park@ahnlab.com>
	<545B1E27.3080302@lab.ntt.co.jp>
	<8D1F1238A24CE743B8F3CED0F137C69E408AA087@EXMB02.ahnbang.ahnlab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=euc-kr
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"bridge@lists.linux-foundation.org" <bridge@lists.linux-foundation.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: =?EUC-KR?B?udq89sf2?= <suhyun.park@ahnlab.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <8D1F1238A24CE743B8F3CED0F137C69E408AA087@EXMB02.ahnbang.ahnlab.com>
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

On 2014/11/06 16:58, =B9=DA=BC=F6=C7=F6 wrote:
>> -----Original Message-----
>> From: Toshiaki Makita [mailto:makita.toshiaki@lab.ntt.co.jp]
>> Sent: Thursday, November 06, 2014 4:07 PM
>> To: =B9=DA=BC=F6=C7=F6; Stephen Hemminger; David S. Miller
>> Cc: bridge@lists.linux-foundation.org; netdev@vger.kernel.org; linux-
>> kernel@vger.kernel.org
>> Subject: Re: [PATCH] bridge: missing null bridge device check causing =
null
>> pointer dereference (bugfix)
>>
>> On 2014/11/06 15:26, Su-Hyun Park wrote:
>>> the bridge device can be null if the bridge is being deleted while
>>> processing the packet, which causes the null pointer dereference in
>> switch statement.
>>
>> How can this happen??
>> It is guarded by rcu.
>> netdev_rx_handler_unregister() ensures rx_handler_data is non NULL.
>>
>=20
> The RCU protect rx_handler_data, not the bridge member port. It can be =
NULL according to below code.
>=20
> static inline struct net_bridge_port *br_port_get_rcu(const struct net_=
device *dev) {
> 	struct net_bridge_port *port =3D rcu_dereference(dev->rx_handler_data)=
;
> 	return br_port_exists(dev) ? port : NULL;=20
> }

Seems to have been fixed for a year.
716ec052d228 ("bridge: fix NULL pointer deref of br_port_get_rcu")

Thanks,
Toshiaki Makita
