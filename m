From: Rui <wirelesser@gmail.com>
Subject: Re: does intel X520-SR(ixgbe) support RSS on single
	VLAN?
Date: Tue, 25 Jan 2011 17:03:10 +0800
Message-ID: <AANLkTik9bcRjJ4N7_rny_pf6qzR2RbUZRKtz5y9sW0Sb@mail.gmail.com>
References: <AANLkTinuozfPcAZStV-a=siqcLesqPHnGhVh=QitOnQs@mail.gmail.com>
	<4D3DB248.5070802@intel.com>
	<AANLkTimFuUp+wbgJY4koZ96st1eBbFqVOxOPj4tU_-Ao@mail.gmail.com>
	<1295924734.2896.6.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1295924734.2896.6.camel@localhost>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Tue, Jan 25, 2011 at 11:05 AM, Ben Hutchings
<bhutchings@solarflare.com> wrote:
> On Tue, 2011-01-25 at 10:10 +0800, Rui wrote:
>> On Tue, Jan 25, 2011 at 1:09 AM, Alexander Duyck
>> <alexander.h.duyck@intel.com> wrote:
>> > On 1/24/2011 6:18 AM, Rui wrote:
>> >>
>> >> hi
>> >> does intel X520-SR support RSS on single VLAN?
>> >>
>> >> tested with 3 different vlan id and priority packets
>> >> What I saw is that all packets were always delivered to the same RxQ.
>> >> looks can not get a different RSS index for these packet?
>> >> any setting needed?
>> >> --
>> >> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> >> the body of a message to majordomo@vger.kernel.org
>> >> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>> >
>> > The X520 should have no problems hashing on a single VLAN tagged frame.
>> > =A0However the VLAN will not be a part of the RSS hash. =A0The =A0only=
 components
>> > of the hash are the IPv4/IPv6 source and destination addresses, and if=
 the
>> > flow is TCP then the port numbers.
>> >
>> hi alexander
>> I got these information from the intel community:
>>
>> 'I asked our software engineers about your question, and this is what I =
learned.
>> You cannot filter by just VLAN or VLAN priority. =A0The L4 type will
>> also play a role in the filter and as such you would only be able to
>> filter TCP, UDP, and SCTP packets that are bound for a VLAN.
>> The command itself to setup a filter is =93ethtool =96U ethX flow-type
>> tcp4 vlan 0x2000 vlan-mask 0xE000 action Y=94 where X is the correct
>> index for the interface and Y is the queue you want to route the
>> traffic to. =A0This would have to be repeated for udp4 and sctp4.
>> I hope this will help.
>> Mark H"
>
> The mask specifies bits to be ignored, so if you want to filter on the
> basis of only the priority bits you should use vlan-mask 0xfff. =A0Unless
> this is another inconsistency I failed to notice...
>
>> so my question is that the VLAN is PART of the RSS or not?
>
> It's not part of any specified Toeplitz hash. =A0However, some hardware
> supports adding the hash (after indirection) to the queue number
> specified by a filter. =A0Currently the ethtool API doesn't have a way to
> request that.
>
>> looks the
>> perfect filter support vlan id ?can the perfect filter support
>> wildchar,such as: flow-type ANY?
>
> It is possible to specify this using flow-type ether, but the ixgbe
> driver does not yet support that (and I have no idea whether the
> hardware does).
>
> Ben.
>
> --
> Ben Hutchings, Senior Software Engineer, Solarflare Communications
> Not speaking for my employer; that's the marketing department's job.
> They asked us to note that Solarflare product names are trademarked.
>
>

I got this msg:
Cannot add new RX n-tuple filter: Operation not supported
This command is only supported after 2.6.34?

---------------------------------------------------------------------------=
---
Special Offer-- Download ArcSight Logger for FREE (a $49 USD value)!
Finally, a world-class log management solution at an even better price-free!
Download using promo code Free_Logger_4_Dev2Dev. Offer expires =

February 28th, so secure your free ArcSight Logger TODAY! =

http://p.sf.net/sfu/arcsight-sfd2d
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.co=
m/community/wired
