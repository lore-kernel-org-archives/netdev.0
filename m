From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: RFC: bridge get fdb by bridge device
Date: Tue, 11 Feb 2014 16:04:52 -0500
Message-ID: <52FA9074.2060900@mojatatu.com>
References: <52F21F72.2090405@mojatatu.com> <52F29747.7040008@redhat.com> <52F3CF76.9090404@mojatatu.com> <52F3E357.4040006@redhat.com> <52F79990.3000400@mojatatu.com> <52F8FEF1.60407@redhat.com> <52FA58E9.906@mojatatu.com> <52FA6A24.3030402@redhat.com> <52FA84FA.2030608@mojatatu.com> <52FA8865.1070302@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: vyasevic@redhat.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Scott Feldman <sfeldma@cumulusnetworks.com>
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:35241 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756034AbaBKVEy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Feb 2014 16:04:54 -0500
Received: by mail-ig0-f181.google.com with SMTP id j1so9751251iga.2
        for <netdev@vger.kernel.org>; Tue, 11 Feb 2014 13:04:53 -0800 (PST)
In-Reply-To: <52FA8865.1070302@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/11/14 15:30, John Fastabend wrote:
> On 2/11/2014 12:15 PM, Jamal Hadi Salim wrote:

Thanks for the example on the other email.


> What do you mean by "bridge device" are you specifically talking about
> IFF_BRIDGE flag? This flag is used only for ./net/bridge devices.

Right - the simple definition is this thing has an fdb.
Yes, I know weve added vlan filtering and multicast snooping
but thats all lipstick. If it has an (ethernet) fdb it is a bridge.

>For
> example macvlan uses its own flag. I think there is a good case to be
> made for netdevices which are acting as the management interface for a
> hardware bridge to set an identifying flag. Perhaps IFF_HWBRIDGE.
>

If you introduce IFF_HWBRIDGE - I think that would satisfy the
distinction. The question then is why not just tag it IFF_BRIDGE?

>
> # ip link set dev bridge0 master bridge1
> RTNETLINK answers: Too many levels of symbolic links
>

pourquoi?  If the original rationale was to limit the
broadcast domain scope it sounds strange that a bridge in
the form a macvlan is allowed.

> in the bridge case this doesn't work. But you can stack a macvlan
> on top of the bridge port,
>
> # ip link add link bridge0 type macvlan mode vepa
>
> 11: macvlan0@bridge0: <BROADCAST,MULTICAST,M-DOWN> mtu 1500 qdisc noop
> state DOWN mode DEFAULT group default
>
> And macvlans on macvlans is OK as well.
>
> # ip link add link macvlan0 type macvlan mode vepa
>
> [...]
>

Ok, I need to let that sink in. Cool actually.


>
> If its useful then we should. You can track them down in userspace
> via /sys/class/net/ or looking for offloaded netdevices that point
> to the interface but a flag is definitely more direct.
>

I prefer a flag. Then i can deal with it via netlink.

cheers,
jamal
