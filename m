From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: Re: [PATCH 3/3] bridge;
 Automatically filter vlans configured on top of bridge
Date: Tue, 16 Sep 2014 20:28:01 +0900
Message-ID: <54181EC1.2010608@lab.ntt.co.jp>
References: <1410554691-18467-1-git-send-email-vyasevic@redhat.com>
	<1410554691-18467-4-git-send-email-vyasevic@redhat.com>
	<5415B6C2.5030702@gmail.com> <54170372.4080903@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, bridge@lists.linux-foundation.org
To: vyasevic@redhat.com, Toshiaki Makita <toshiaki.makita1@gmail.com>,
	Vladislav Yasevich <vyasevich@gmail.com>, netdev@vger.kernel.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <54170372.4080903@redhat.com>
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

On 2014/09/16 0:19, Vlad Yasevich wrote:
> On 09/14/2014 11:39 AM, Toshiaki Makita wrote:
>> (14/09/13 (土) 5:44), Vladislav Yasevich wrote:
>>> If the user configures vlan devices on top of the bridge,
>>> automatically set up filter entries for it as long as
>>> bridge vlan protocol matches that of the vlan.
>>> This allows the user to atomatically receive vlan traffic
>>> for the vlans that are convifgured.
>>
>> Changing br->vlan_proto seems to cause inconsistency between vlan
>> interfaces and filter settings.
>> Can we automatically change filters when setting vlan_proto?
>>
> 
> I thought we already do that in br_vlan_set_proto()?  Nothing
> here introduces any new kinds of issue with that code.

I'm referring to a case like this:
1. create br0.10 (802.1ad)
2. change br->vlan_proto into 88a8

When creating br0.10 (1), br->vlan_proto is 8100 and different from
protocol of br0.10, so it is ignored by br_vlan_rx_add_vid().
After changing br->vlan_proto (2), we might expect vlan 10 is not
filtered on br0, but it will be filtered.

Thanks,
Toshiaki Makita
