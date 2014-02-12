From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: RFC: bridge get fdb by bridge device
Date: Wed, 12 Feb 2014 10:50:42 -0800
Message-ID: <52FBC282.6020301@intel.com>
References: <52F21F72.2090405@mojatatu.com> <52F29747.7040008@redhat.com> <52F3CF76.9090404@mojatatu.com> <52F3E357.4040006@redhat.com> <52F79990.3000400@mojatatu.com> <52F8FEF1.60407@redhat.com> <52FA58E9.906@mojatatu.com> <52FA6A24.3030402@redhat.com> <52FA84FA.2030608@mojatatu.com> <52FA8865.1070302@intel.com> <52FA9074.2060900@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: vyasevic@redhat.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Scott Feldman <sfeldma@cumulusnetworks.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:22127 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752814AbaBLSun (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Feb 2014 13:50:43 -0500
In-Reply-To: <52FA9074.2060900@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/11/2014 1:04 PM, Jamal Hadi Salim wrote:
> On 02/11/14 15:30, John Fastabend wrote:
>> On 2/11/2014 12:15 PM, Jamal Hadi Salim wrote:
>
> Thanks for the example on the other email.
>

Just to wrap things up in one email. Changing between VEB and VEPA
modes already triggers an event. So management applications can listen
for this.

And I can send out a patch to add a flag to hardware bridge devices
I'll likely get to it next week sometime unless someone beats me
to it.

>
>> What do you mean by "bridge device" are you specifically talking about
>> IFF_BRIDGE flag? This flag is used only for ./net/bridge devices.
>
> Right - the simple definition is this thing has an fdb.
> Yes, I know weve added vlan filtering and multicast snooping
> but thats all lipstick. If it has an (ethernet) fdb it is a bridge.
>

Sure, IEEE802.1Q would call these edge relays.

>> For
>> example macvlan uses its own flag. I think there is a good case to be
>> made for netdevices which are acting as the management interface for a
>> hardware bridge to set an identifying flag. Perhaps IFF_HWBRIDGE.
>>
>
> If you introduce IFF_HWBRIDGE - I think that would satisfy the
> distinction. The question then is why not just tag it IFF_BRIDGE?
>

Because it is not the same type of object as the software bridge.
Most notably it doesn't do learning. If anything its more like a
macvlan device and we could just as easily tag it IFF_MACVLAN. So
because it doesn't really match 1:1 with either of those object I
would just presume give its own flag. Userspace can always create
a small macro call it is_bridge_like() and check for any of the
handful of bridge like objects.

>>
>> # ip link set dev bridge0 master bridge1
>> RTNETLINK answers: Too many levels of symbolic links
>>
>
> pourquoi?  If the original rationale was to limit the
> broadcast domain scope it sounds strange that a bridge in
> the form a macvlan is allowed.
>

Agreed. But there it is.

>> in the bridge case this doesn't work. But you can stack a macvlan
>> on top of the bridge port,
>>
>> # ip link add link bridge0 type macvlan mode vepa
>>
>> 11: macvlan0@bridge0: <BROADCAST,MULTICAST,M-DOWN> mtu 1500 qdisc noop
>> state DOWN mode DEFAULT group default
>>
>> And macvlans on macvlans is OK as well.
>>
>> # ip link add link macvlan0 type macvlan mode vepa
>>
>> [...]
>>
>
> Ok, I need to let that sink in. Cool actually.
>

Also note you can mix VEB and VEPA modes and if you do it correctly
can create blocks of virtual ports that can do east-west traffic and
isolate others.

>
>>
>> If its useful then we should. You can track them down in userspace
>> via /sys/class/net/ or looking for offloaded netdevices that point
>> to the interface but a flag is definitely more direct.
>>
>
> I prefer a flag. Then i can deal with it via netlink.
>

OK. I'll add one here shortly.

> cheers,
> jamal
>
