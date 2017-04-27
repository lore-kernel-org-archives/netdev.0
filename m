From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH net-next 1/2] rtnetlink: Disable notification for
 NETDEV_NAMECHANGE event
Date: Thu, 27 Apr 2017 15:26:53 -0400
Message-ID: <8a873778-5e0f-7376-168c-7cf6fa6df41a@redhat.com>
References: <1492795881-11914-1-git-send-email-vyasevic@redhat.com>
 <1492795881-11914-2-git-send-email-vyasevic@redhat.com>
 <becfb3d4-5e9d-800b-fc67-1e99f4b14db9@cumulusnetworks.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
To: David Ahern <dsa@cumulusnetworks.com>,
        Vladislav Yasevich <vyasevich@gmail.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56564 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1033701AbdD0T06 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 27 Apr 2017 15:26:58 -0400
In-Reply-To: <becfb3d4-5e9d-800b-fc67-1e99f4b14db9@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/21/2017 02:08 PM, David Ahern wrote:
> On 4/21/17 11:31 AM, Vladislav Yasevich wrote:
>> The data signaling name change is already provided at
>> the end of do_setlink().  This event handler just generates
>> a duplicate announcement.  Disable it.
>>
>> CC: David Ahern <dsa@cumulusnetworks.com>
>> Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
>> ---
>>  net/core/rtnetlink.c | 1 -
>>  1 file changed, 1 deletion(-)
>>
>> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
>> index 0ee5479..e8e6816 100644
>> --- a/net/core/rtnetlink.c
>> +++ b/net/core/rtnetlink.c
>> @@ -4123,7 +4123,6 @@ static int rtnetlink_event(struct notifier_block *this, unsigned long event, voi
>>  
>>  	switch (event) {
>>  	case NETDEV_REBOOT:
>> -	case NETDEV_CHANGENAME:
>>  	case NETDEV_FEAT_CHANGE:
>>  	case NETDEV_BONDING_FAILOVER:
>>  	case NETDEV_NOTIFY_PEERS:
>>
> 
> 
> I only see one using the ip monitor.
> 
> $ ip li set foobar name fubar
> 
> generates these 3 messages:
> 
> [LINK]12: fubar: <BROADCAST,NOARP> mtu 1500 qdisc noqueue state DOWN
> group default
>     link/ether 76:cd:72:dd:2a:cb brd ff:ff:ff:ff:ff:ff
> Unknown message: type=0x00000051(81) flags=0x00000000(0)len=0x0000001c(28)
> [NETCONF]ipv4 dev dummy2 forwarding on rp_filter off mc_forwarding off
> proxy_neigh off ignore_routes_with_linkdown off
> Unknown message: type=0x00000051(81) flags=0x00000000(0)len=0x0000001c(28)
> [NETCONF]ipv6 dev dummy2 forwarding on mc_forwarding off proxy_neigh off
> ignore_routes_with_linkdown off
> 
> do_setlink only sets DO_SETLINK_MODIFIED so a name change alone will not
> generate 2 messages.
> 

Actually, it has nothing to do with above flag.  Setting DO_SETLINK_MODIFIED
will still generate notifications, but only if the device is UP.  However,
it looks like link name change can only be done when the link is down.  As
a result, netdev_state_change will not report it, so we only see the 'event'
one.

So this is patch isn't needed, but only as a kind-of side-effect..

-vlad
