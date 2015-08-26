From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2] bridge: vlan: allow to suppress
	local mac install for all vlans
Date: Tue, 25 Aug 2015 22:42:49 -0700
Message-ID: <B58362A0-3860-42AB-A13A-8158891EC956@cumulusnetworks.com>
References: <1440549295-3979-1-git-send-email-razor@blackwall.org>
	<20150825175627.66ca9f30@urahara>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2098\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: vyasevic@redhat.com, bridge@lists.linux-foundation.org,
	netdev@vger.kernel.org, wkok@cumulusnetworks.com, davem@davemloft.net
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20150825175627.66ca9f30@urahara>
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


> On Aug 25, 2015, at 5:56 PM, Stephen Hemminger =
<stephen@networkplumber.org> wrote:
>=20
> On Tue, 25 Aug 2015 17:34:55 -0700
> Nikolay Aleksandrov <razor@blackwall.org> wrote:
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
>=20
>=20
> This is getting messy, but then again the bridge seems to have become
> a ghetto for a long time. I would rather see the lookup code fixed so
> that the fdb was correct.

What do you mean by it is getting messy ? The entries (normally) are =
being added to each
vlan so there=E2=80=99s not much in terms of lookup that you can fix =
except making the table bigger/better
but that will be only a temporary win. If you elaborate on what you mean =
by fdb code being fixed
I could spend time and work on fixing it. If it is resizing the table so =
it can handle 96k entries and
probably using the rhashtable, that is what I have in mind too.
I still think that it would be nice to have the option to avoid adding =
the 96k entries in the first place
and that space could be better utilized by real ones, which this option =
does.
