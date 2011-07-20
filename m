From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [patch net-next-2.6 37/47] igb: do vlan cleanup
Date: Wed, 20 Jul 2011 21:10:49 +0200
Message-ID: <20110720191045.GD2688@minipsycho.redhat.com>
References: <1311173689-17419-1-git-send-email-jpirko@redhat.com>
	<1311173689-17419-38-git-send-email-jpirko@redhat.com>
	<CAEP_g=_0Ej09+KYbvEJz1+joYtms+S_67XSVVPMoG_hfJnmrBQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	bruce.w.allan@intel.com, jesse.brandeburg@intel.com,
	mirqus@gmail.com, john.ronciak@intel.com,
	shemminger@linux-foundation.org, davem@davemloft.net
To: Jesse Gross <jesse@nicira.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <CAEP_g=_0Ej09+KYbvEJz1+joYtms+S_67XSVVPMoG_hfJnmrBQ@mail.gmail.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Wed, Jul 20, 2011 at 07:35:33PM CEST, jesse@nicira.com wrote:
>On Wed, Jul 20, 2011 at 7:54 AM, Jiri Pirko <jpirko@redhat.com> wrote:
>> @@ -2943,7 +2944,7 @@ static void igb_rlpml_set(struct igb_adapter *adap=
ter)
>> =A0 =A0 =A0 =A0struct e1000_hw *hw =3D &adapter->hw;
>> =A0 =A0 =A0 =A0u16 pf_id =3D adapter->vfs_allocated_count;
>>
>> - =A0 =A0 =A0 if (adapter->vlgrp)
>> + =A0 =A0 =A0 if (igb_vlan_used(adapter))
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0max_frame_size +=3D VLAN_TAG_SIZE;
>
>There are similar issues here as with the VF driver.  I think you're
>also confusing vlan acceleration with vlan filtering.  If no vlan
>filters are in use but the card is in promiscuous mode, the buffer
>will be undersized and we lose tagged packets.

I'm certainly not confusing vlan accel and filtering. Here is the
intension is the behaviour remains intact as well. I believe it's true.

>
>> +static void igb_vlan_mode(struct net_device *netdev, bool vlan_on)
>> =A0{
>> =A0 =A0 =A0 =A0struct igb_adapter *adapter =3D netdev_priv(netdev);
>> =A0 =A0 =A0 =A0struct e1000_hw *hw =3D &adapter->hw;
>> =A0 =A0 =A0 =A0u32 ctrl, rctl;
>>
>> =A0 =A0 =A0 =A0igb_irq_disable(adapter);
>> - =A0 =A0 =A0 adapter->vlgrp =3D grp;
>>
>> - =A0 =A0 =A0 if (grp) {
>> + =A0 =A0 =A0 if (vlan_on) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* enable VLAN tag insert/strip */
>
>This should be controlled by ethtool, not by whether vlan filters are
>enabled.  Essentially, with this, you are recreating the logic of the
>old vlan model in the new one.

---------------------------------------------------------------------------=
---
10 Tips for Better Web Security
Learn 10 ways to better secure your business today. Topics covered include:
Web security, SSL, hacker attacks & Denial of Service (DoS), private keys,
security Microsoft Exchange, secure Instant Messaging, and much more.
http://www.accelacomm.com/jaw/sfnl/114/51426210/
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.co=
m/community/wired
