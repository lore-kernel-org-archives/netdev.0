From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [patch net-next-2.6 18/47] igbvf: do vlan cleanup
Date: Wed, 20 Jul 2011 21:07:06 +0200
Message-ID: <20110720190704.GB2688@minipsycho.redhat.com>
References: <1311173689-17419-1-git-send-email-jpirko@redhat.com>
	<1311173689-17419-19-git-send-email-jpirko@redhat.com>
	<CAEP_g=9D5CEUG7AVxoyW6Q0NUEaQ+vE3g+SPdU677Y+s65JRiA@mail.gmail.com>
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
In-Reply-To: <CAEP_g=9D5CEUG7AVxoyW6Q0NUEaQ+vE3g+SPdU677Y+s65JRiA@mail.gmail.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Wed, Jul 20, 2011 at 07:26:14PM CEST, jesse@nicira.com wrote:
>On Wed, Jul 20, 2011 at 7:54 AM, Jiri Pirko <jpirko@redhat.com> wrote:
>> @@ -1170,19 +1170,28 @@ static void igbvf_set_rlpml(struct igbvf_adapter=
 *adapter)
>> =A0 =A0 =A0 =A0int max_frame_size =3D adapter->max_frame_size;
>> =A0 =A0 =A0 =A0struct e1000_hw *hw =3D &adapter->hw;
>>
>> - =A0 =A0 =A0 if (adapter->vlgrp)
>> + =A0 =A0 =A0 if (adapter->netdev->features & NETIF_F_HW_VLAN_RX)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0max_frame_size +=3D VLAN_TAG_SIZE;
>
>This is unconditionally true, right?  NETIF_F_HW_VLAN_RX never gets
>toggled here.  In any case, I think we should be able to handle vlan
>tagged packets even if stripping isn't enabled.

You are correct. This should be checked rather if any bit of
adapter->active_vlans is set. I'll repost soon.

>
>The Intel guys have expressed some concerns in the past about the MTU
>in relation to the igb driver (the PF version) with vlan tags.  I'm
>not quite sure what about this NIC is different from others in the
>handling of MTU and vlans but here's one such thread:
>http://patchwork.ozlabs.org/patch/82675/

The intension is to make driver to bahave the same as before this patch.

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
