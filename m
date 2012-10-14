From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: regression in bonding driver with VLAN challenged interfaces
 when 8021q module is loaded
Date: Sun, 14 Oct 2012 16:32:37 +0200
Message-ID: <20121014143237.GA2556@minipsycho.orion>
References: <CAJtaB1v95Z2b78cKUPYrZtriF6BuHwD2=StyhV3gGOOquNt7fw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fubar@us.ibm.com, andy@greyhouse.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jpirko@redhat.com
To: Jon Stanley <jstanley@rmrf.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAJtaB1v95Z2b78cKUPYrZtriF6BuHwD2=StyhV3gGOOquNt7fw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thu, Oct 11, 2012 at 04:28:40PM CEST, jstanley@rmrf.net wrote:
>Since commit cc0e40700656b09d93b062ef6c818aa45429d09a, there is a
>problem if you have the 8021q module loaded and you then attempt to
>enslave a VLAN challenged interface. This is because VLAN 0 is
>automatically added to the bond, and the new bond_vlan_used() function
>simply checks for an empty list in bond->vlan_list without taking into
>account that VLAN0 might be on the interface.
>
>This specifically affects IPoIB interfaces in a bond if you do a
>down/up cycle on the bond post-boot (during boot, the bonding module
>is loaded prior to the 8021q module, so everything is fine).
>
>Let me know if further information or testing is needed.

Thanks for the report. I just fixed this by following patch:
http://patchwork.ozlabs.org/patch/191363/
