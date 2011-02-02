From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH v3 1/3] iproute2: add support for setting device groups
Date: Wed, 02 Feb 2011 10:21:36 +0100
Message-ID: <4D492220.8030509@trash.net>
References: <1296060086-18777-1-git-send-email-ddvlad@rosedu.org> <1296060086-18777-2-git-send-email-ddvlad@rosedu.org> <4D491C3C.2010805@trash.net> <20110202091315.GJ2494@cormyr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>
To: Vlad Dogaru <ddvlad@rosedu.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:63791 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751035Ab1BBJVu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Feb 2011 04:21:50 -0500
In-Reply-To: <20110202091315.GJ2494@cormyr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02.02.2011 10:13, Vlad Dogaru wrote:
> On Wed, Feb 02, 2011 at 09:56:28AM +0100, Patrick McHardy wrote:
>> On 26.01.2011 17:41, Vlad Dogaru wrote:
>>> Use the group keyword to specify what group the device should belong to.
>>> Since the kernel uses numbers internally, mapping of group names to
>>> numbers is defined in /etc/iproute2/group_map. Example usage:
>>>
>>>   ip link set dev eth0 group default
>>>
>>> @@ -297,6 +299,13 @@ int iplink_parse(int argc, char **argv, struct iplink_req *req,
>>>  			if (get_integer(&mtu, *argv, 0))
>>>  				invarg("Invalid \"mtu\" value\n", *argv);
>>>  			addattr_l(&req->n, sizeof(*req), IFLA_MTU, &mtu, 4);
>>> +		} else if (strcmp(*argv, "group") == 0) {
>>> +			NEXT_ARG();
>>> +			if (group != -1)
>>> +				duparg("group", *argv);
>>> +			if (lookup_map_id(*argv, &group, GROUP_MAP))
>>> +				invarg("Invalid \"group\" value\n", *argv);
>>> +			addattr_l(&req->n, sizeof(*req), IFLA_GROUP, &group, 4);
>>
>> I think it would be preferrable to use a function similar to
>> rt_realm_n2a() that can also handle plain numerical values.
> 
> The a2n() functions are rather complex for this case: they employ
> caching and store a table. I suppose this is because multiple calls to
> them are possible in a single run and the correspondence has to be made
> in both ways (a2n and n2a).
> 
> A network group is only converted to a number at most once for each ip
> process spawned, so storing a table is not really helpful. What could,
> however, help is using get_integer before lookup_map_id. Only if
> get_integer fails would we lookup the symbolic group name.
> 
> Does that make sense?

Sure, that would be fine as well.

One more thing I find confusing is that for assigning a group
to a device the parameter is called "group", for performing
actions on a group its called "devgroup". Why not simply use
"group" for both cases? The case "ip link set devgroup X group Y"
doesn't work anyways since the IFLA_GROUP attribute is used
for both.
