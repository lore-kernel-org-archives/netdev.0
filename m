From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: Re: [PATCH 0/3] bridge: Some nice new things for vlan
	filtering
Date: Tue, 16 Sep 2014 20:38:39 +0900
Message-ID: <5418213F.2050105@lab.ntt.co.jp>
References: <1410554691-18467-1-git-send-email-vyasevic@redhat.com>
	<20140915092405.124ff9d0@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable
Cc: Vladislav Yasevich <vyasevic@redhat.com>, netdev@vger.kernel.org,
	shemminger@vyatta.com, bridge@lists.linux-foundation.org
To: Stephen Hemminger <stephen@networkplumber.org>,
	Vladislav Yasevich <vyasevich@gmail.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20140915092405.124ff9d0@urahara>
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

On 2014/09/16 1:24, Stephen Hemminger wrote:
> On Fri, 12 Sep 2014 16:44:48 -0400
> Vladislav Yasevich <vyasevich@gmail.com> wrote:
>=20
>> While working with vlan filtering and non-promisc mode, I've found
>> myself wanting untagged traffic to automatically pass through the
>> bridge.  So I decided to introduce the concept of a per bridge default
>> pvid.  VLAN 1 is used as default pvid by default and can be changed
>> by user through sysfs while vlan filtering is off. (I'll be adding net=
link
>> support now that Jiri Pirko kindly added the ifrastructure).  Default
>> pvid is assigned to all ports that do not assign their own pvid or
>> already have a given vlan configured.  This makes it very simple
>> to enable vlan filtering on the bridge, not have to configure a thing,
>> and still pass untagged traffic.
>>
>> The other small thing this series adds is automatic update of the
>> vlan filter when vlan is configured on top of the bridge.  In this
>> case we automatically add the given vlan to the bridge filter list.
>> The ports may still need to be updated as we don't know which ports
>> are allowed to receive a given vlan.
>>
>> Thanks
>> -vlad
>>
>> Vladislav Yasevich (3):
>>   bridge: Add a default_pvid sysfs attribute
>>   bridge: Add filtering support for default_pvid
>>   bridge; Automatically filter vlans configured on top of bridge
>>
>>  net/bridge/br_device.c   |  54 +++++++++++++++++++---
>>  net/bridge/br_if.c       |   2 +
>>  net/bridge/br_private.h  |  35 ++++++++++++++-
>>  net/bridge/br_sysfs_br.c |  17 +++++++
>>  net/bridge/br_vlan.c     | 113 ++++++++++++++++++++++++++++++++++++++=
++++++++-
>>  5 files changed, 213 insertions(+), 8 deletions(-)
>>
>=20
> Please, no special VLAN 1, other equipment has that silliness.
>=20
> Why is untagged traffic not treated as VLAN 0?

I guess it's respecting 802.1Q spec.

  Table 9-2=97Reserved VID values

  VID value: 1
  The default PVID value used for classifying frames on ingress through
  a Bridge Port. The PVID value of a Port can be changed by management.

Thanks,
Toshiaki Makita
