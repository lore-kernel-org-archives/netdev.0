From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Subject: Re: [Xen-devel] [RFC v2 1/4] bridge: enable interfaces to
 opt out from becoming the root bridge
Date: Wed, 19 Feb 2014 08:45:55 -0800
Message-ID: <CAB=NE6XYjOd2vRpQCZOG-S5ZW4xjam+FOPAYzribNQpb50Q5pg@mail.gmail.com>
References: <1392433180-16052-1-git-send-email-mcgrof@do-not-panic.com>
	<1392433180-16052-2-git-send-email-mcgrof@do-not-panic.com>
	<53024C58.4010900@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: kvm@vger.kernel.org, "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	bridge@lists.linux-foundation.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	xen-devel@lists.xenproject.org
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <53024C58.4010900@citrix.com>
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

On Mon, Feb 17, 2014 at 9:52 AM, Zoltan Kiss <zoltan.kiss@citrix.com> wrote:
> On 15/02/14 02:59, Luis R. Rodriguez wrote:
>>
>> From: "Luis R. Rodriguez" <mcgrof@suse.com>
>>
>> It doesn't make sense for some interfaces to become a root bridge
>> at any point in time. One example is virtual backend interfaces
>> which rely on other entities on the bridge for actual physical
>> connectivity. They only provide virtual access.
>
> It is possible that a guest bridge together to VIF, either from the same
> Dom0 bridge or from different ones. In that case using STP on VIFs sound
> sensible to me.

You seem to describe a case whereby it can make sense for xen-netback
interfaces to end up becoming the root port of a bridge. Can you
elaborate a little more on that as it was unclear the use case.

Additionally if such cases exist then under the current upstream
implementation one would simply need to change the MAC address in
order to enable a vif to become the root port.  Stephen noted there is
a way to avoid nominating an interface for a root port through the
root block flag. We should use that instead of the MAC address hacks.
Let's keep in mind that part of the motivation for this series is to
avoid a duplicate IPv6 address left in place by use cases whereby the
MAC address of the backend vif was left static. The use case your are
explaining likely describes the more prevalent use case where address
conflicts can occur, perhaps when administrators for got to change the
backend MAC address. If we embrace a random MAC address we'd avoid
that issue, and but we'd need to update userspace to use the root
block on topologies where desired.

  Luis
