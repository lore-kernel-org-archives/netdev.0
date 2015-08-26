From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2] bridge: vlan: allow to suppress
	local mac install for all vlans
Date: Tue, 25 Aug 2015 22:28:16 -0700
Message-ID: <E065D3DC-6CBC-4625-8800-5133E21C5483@cumulusnetworks.com>
References: <1440549295-3979-1-git-send-email-razor@blackwall.org>
	<20150825.194222.390859854071446877.davem@davemloft.net>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2098\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: vyasevic@redhat.com, bridge@lists.linux-foundation.org,
	netdev@vger.kernel.org, wkok@cumulusnetworks.com
To: David Miller <davem@davemloft.net>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20150825.194222.390859854071446877.davem@davemloft.net>
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


> On Aug 25, 2015, at 7:42 PM, David Miller <davem@davemloft.net> wrote:
>=20
> From: Nikolay Aleksandrov <razor@blackwall.org>
> Date: Tue, 25 Aug 2015 17:34:55 -0700
>=20
>> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>>=20
>> This patch adds a new knob that, when enabled, allows to suppress the
>> installation of local fdb entries in newly created vlans. This could
>> pose a big scalability issue if we have a large number of ports and a
>> large number of vlans, e.g. in a 48 port device with 2000 vlans these
>> entries easily go up to 96000.
>> Note that packets for these macs are still received properly because =
they
>> are added in vlan 0 as "own" macs and referenced when fdb lookup by =
vlan
>> results in a miss.
>> Also note that vlan membership of ingress port and the bridge device
>> as egress are still being correctly enforced.
>>=20
>> The default (0/off) is keeping the current behaviour.
>>=20
>> Based on a patch by Wilson Kok (wkok@cumulusnetworks.com).
>>=20
>> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>> ---
>> v2: Triple checked the timezone
>=20
> I'd rather we fix the essence of the scalability problem than add
> more spaghetti code to the various bridge paths.
>=20
> Can we make the fdb entries smaller?
>=20
> Can we enhance how we store such local entries such that they live in
> a compact datastructure?  Perhaps the FDB can consist of a very dense
> lookup mechanism for local stuff sitting alongside the current table.

Certainly, that should be done and I will look into it, but the essence =
of this patch
is a bit different. The problem here is not the size of the fdb entries, =
it=E2=80=99s more the
number of them - having 96000 entries (even if they were 1 byte ones) is =
just way
too much especially when the fdb hash size is small and static. We could =
work on making
it dynamic though, but still these type of local entries per vlan per =
port can easily be avoided
with this option.
