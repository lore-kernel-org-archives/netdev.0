From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 3/5] e1000e: Allow TSO to trickle down to
	VLAN device
Date: Wed, 30 Apr 2008 08:56:22 +0200
Message-ID: <48181816.2050904@trash.net>
References: <20080414170557.23286.71580.stgit@localhost.localdomain>
	<20080414170609.23286.42880.stgit@localhost.localdomain>
	<4803903B.1020100@trash.net> <4807C516.90308@intel.com>
	<480CA399.50708@trash.net>
	<D5C1322C3E673F459512FB59E0DDC32904FE0E6B@orsmsx414.amr.corp.intel.com>
	<481817AD.1010306@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	"Kok,  Auke-jan H" <auke-jan.h.kok@intel.com>, jeff@garzik.org
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <481817AD.1010306@trash.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> Waskiewicz Jr, Peter P wrote:
>>> In any case I would prefer to avoid having drivers mess with VLAN
>>> device flags. How about adding a device flag indicating that the
>>> driver supports TSO + VLAN acceleration and using the
>>> NETDEV_FEAT_CHANGE notification inside the VLAN code do adjust
>>> the device's flags properly?
>>
>> I've been looking into this, and I agree this makes sense when creating
>> a new VLAN to get the device flags to the VLAN device.  However, we need
>> to get the TSO and/or Tx checksum offload feature flags off all VLAN
>> devices when the parent device has it turned off.  I don't see any clean
>> way of doing this with netdev_features_change().  I'd really love to
>> implement this correctly, so if you have any ideas on how to handle this
>> latter case, I'm all ears.  :-)
> 
> 
> Whats the problem with doing:
> 
> - on VLAN creation: copy VLAN flag from lower device if lowerdev
                            ^^^^ TSO/checksumming flags
>   has NETIF_F_<flag indicating non-broken TSO+VLAN accel>
> 
> - on change of TSO/checksumming flags of lower device:
>   use netdevice notifier to adjust the settings for all
>   VLANs on that device

-------------------------------------------------------------------------
This SF.net email is sponsored by the 2008 JavaOne(SM) Conference 
Don't miss this year's exciting event. There's still time to save $100. 
Use priority code J8TL2D2. 
http://ad.doubleclick.net/clk;198757673;13503038;p?http://java.sun.com/javaone
