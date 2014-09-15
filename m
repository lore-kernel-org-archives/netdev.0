From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH 3/3] bridge;
 Automatically filter vlans configured on top of bridge
Date: Mon, 15 Sep 2014 11:19:14 -0400
Message-ID: <54170372.4080903@redhat.com>
References: <1410554691-18467-1-git-send-email-vyasevic@redhat.com>
	<1410554691-18467-4-git-send-email-vyasevic@redhat.com>
	<5415B6C2.5030702@gmail.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, bridge@lists.linux-foundation.org
To: Toshiaki Makita <toshiaki.makita1@gmail.com>,
	Vladislav Yasevich <vyasevich@gmail.com>, netdev@vger.kernel.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <5415B6C2.5030702@gmail.com>
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

On 09/14/2014 11:39 AM, Toshiaki Makita wrote:
> (14/09/13 (土) 5:44), Vladislav Yasevich wrote:
>> If the user configures vlan devices on top of the bridge,
>> automatically set up filter entries for it as long as
>> bridge vlan protocol matches that of the vlan.
>> This allows the user to atomatically receive vlan traffic
>> for the vlans that are convifgured.
> 
> Changing br->vlan_proto seems to cause inconsistency between vlan
> interfaces and filter settings.
> Can we automatically change filters when setting vlan_proto?
> 

I thought we already do that in br_vlan_set_proto()?  Nothing
here introduces any new kinds of issue with that code.

>>
> ...
>> +static int br_vlan_rx_kill_vid(struct net_device *br_dev,
>> +			       __be16 proto, u16 vid)
> ...
>> +	/* Don't report error.  This will fail if the vlan was
>> +	 * previousely remove by some other means and we don't
>> +	 * wan't to polute the log/bug the user.
>> +	 */
>> +	br_vlan_delete(br, vid);
>> +	return 0;
>> +}
> 
> It might lead to unexpected behaviour, for example,
> 1. create br0.10
> 2. set pvid to 10 on br0
> 3. delete br0.10
> Then, pvid will also be cleared?
> Something like ref counting is needed?

Gah!  The bitmap implementation is really starting to annoy me.  Yes, it's fast, but it
is so restrictive...

We'd need tracking per vlan id and we can't that right now.  OK, this one needs more
thought.  I'll drop it for now.

Thanks
-vlad
> 
> Thanks,
> Toshiaki Makita
> 
