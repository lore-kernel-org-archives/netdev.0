From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] Bridge: Fix ipv6 mc snooping if bridge has
 no ipv6 address
Date: Tue, 28 Jun 2016 08:04:42 -0400 (EDT)
Message-ID: <20160628.080442.1941457943482109633.davem@davemloft.net>
References: <1466764518-11358-1-git-send-email-daniel@dd-wrt.com>
	<20160625142028.GF4407@otheros>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, ulrich.weber@sophos.com, uw@ocedo.com
To: linus.luessing@c0d3.blue
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20160625142028.GF4407@otheros>
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

From: Linus L=FCssing <linus.luessing@c0d3.blue>
Date: Sat, 25 Jun 2016 16:20:28 +0200

> On Fri, Jun 24, 2016 at 12:35:18PM +0200, Daniel Danzberger wrote:
>> The bridge is falsly dropping ipv6 mulitcast packets if there is:
>>  1. No ipv6 address assigned on the brigde.
>>  2. No external mld querier present.
>>  3. The internal querier enabled.
>> =

>> When the bridge fails to build mld queries, because it has no
>> ipv6 address, it slilently returns, but keeps the local querier enab=
led.
>> This specific case causes confusing packet loss.
>> =

>> Ipv6 multicast snooping can only work if:
>>  a) An external querier is present
>>  OR
>>  b) The bridge has an ipv6 address an is capable of sending own quer=
ies
>> =

>> Otherwise it has to forward/flood the ipv6 multicast traffic,
>> because snooping cannot work.
>> =

>> This patch fixes the issue by adding a flag to the bridge struct tha=
t
>> indicates that there is currently no ipv6 address assinged to the br=
idge
>> and returns a false state for the local querier in
>> __br_multicast_querier_exists().
> =

> Fixes: 1d81d4c3dd88 ("bridge: check return value of ipv6_dev_get_sadd=
r()")

You're missing an initial 'd' in that SHA1-ID.

With that fixed, applied and queued up for -stable.
