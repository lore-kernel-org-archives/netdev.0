From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [patch 1/1][NETNS][IPV6] protect addrconf from loopback
	registration
Date: Mon, 12 Nov 2007 09:51:58 -0700
Message-ID: <m1ejev4dap.fsf@ebiederm.dsl.xmission.com>
References: <20071112151953.052335971@mai.toulouse-stg.fr.ibm.com>
	<20071112152403.273795630@mai.toulouse-stg.fr.ibm.com>
	<473879C3.5020301@sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org,
        Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
        xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
To: "Denis V. Lunev" <den-3ImXcnM4P+0@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <473879C3.5020301-3ImXcnM4P+0@public.gmane.org> (Denis V. Lunev's message of "Mon, 12
	Nov 2007 19:05:23 +0300")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

"Denis V. Lunev" <den-3ImXcnM4P+0@public.gmane.org> writes:

>> Index: linux-2.6-netns/net/ipv6/addrconf.c
>> ===================================================================
>> --- linux-2.6-netns.orig/net/ipv6/addrconf.c
>> +++ linux-2.6-netns/net/ipv6/addrconf.c
>> @@ -2272,7 +2272,8 @@ static int addrconf_notify(struct notifi
>>  
>>  	switch(event) {
>>  	case NETDEV_REGISTER:
>> -		if (!idev && dev->mtu >= IPV6_MIN_MTU) {
>> +		if (!(dev->flags & IFF_LOOPBACK) &&
>> +		    !idev && dev->mtu >= IPV6_MIN_MTU) {

It is idev being true here for the loopback device that would
prevent things not missing the REGISTER event.

Hmm.  But we do call ipv6_add_dev on loopback and now the loopback
device is practically guaranteed to be the first device so we can
probably just remove the special case in addrconf_init.

Anyway Daniels patch makes increasingly less sense the more I look
at it.


> Namespaces are good to catch leakage using standard codepaths, so they
> should be preserved as much as possible. So, _all_ normal down code
> should be called for a loopback device in other than init_net context.

In any context. After the code path is aware of multiple network namespaces
init_net should not be special in any way.

I completely agree about the ability to catch weird leakage scenarios.

Eric
