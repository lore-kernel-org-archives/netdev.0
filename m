From: Veaceslav Falico <vfalico@gmail.com>
Subject: Re: [PATCH v2 net-next 1/2] net: use dev->name in netdev_pr* when
 it's available
Date: Thu, 17 Jul 2014 18:38:13 +0200
Message-ID: <20140717163812.GA20406@mikrodark.usersys.redhat.com>
References: <1405606186-13703-1-git-send-email-vfalico@gmail.com>
 <1405606186-13703-2-git-send-email-vfalico@gmail.com>
 <1405613924.12363.24.camel@joe-AO725>
 <20140717162553.GD28357@mikrodark.usersys.redhat.com>
 <1405614968.12363.28.camel@joe-AO725>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Tom Gundersen <teg@jklm.no>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f48.google.com ([74.125.82.48]:43590 "EHLO
	mail-wg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934651AbaGQQlM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2014 12:41:12 -0400
Received: by mail-wg0-f48.google.com with SMTP id x13so2234573wgg.31
        for <netdev@vger.kernel.org>; Thu, 17 Jul 2014 09:41:10 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1405614968.12363.28.camel@joe-AO725>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 17, 2014 at 09:36:08AM -0700, Joe Perches wrote:
>On Thu, 2014-07-17 at 18:25 +0200, Veaceslav Falico wrote:
>> On Thu, Jul 17, 2014 at 09:18:44AM -0700, Joe Perches wrote:
>> >On Thu, 2014-07-17 at 16:09 +0200, Veaceslav Falico wrote:
>> >> netdev_name() returns dev->name only when the net_device is in
>> >> NETREG_REGISTERED state.
>[]
>> >Maybe this should not be inline and become something like:
>>
>> It will miss the states then, when it's not NETREG_REGISTERED.
>
>If it's registered, it has a valid name via
>dev_get_valid_name() doesn't it?

Yes, I'm speaking about the NETREG_* states when it's not registered.

i.e.:

Jul 17 13:35:29 darkmag kernel: [  602.686489] bond2 (unregistering): Released all slaves

that's with my patchset, when the bond device is unregistering
(NETREG_UNREGISTERING). With your patch it would be only "bond2: Released
all slaves".

As the most time the device is in the NETREG_REGISTERED state, there will
be no differencies in the output (with either my or your approach), however
in less-common states/codepaths it will also output its state, which might
be quite valuable when analyzing the logs.

>
>> >const char *netdev_name(const struct net_device *dev)
>> >{
>> >	if (dev->reg_state == NETREG_REGISTERED)
>> >		return dev->name;
>> >
>> >	if (!dev->name[0])
>> >		return "(unnamed net_device)";
>> >
>> >	if (!strchr(dev->name, '%'))
>> >		return "(unregistered net_device)";
>> >
>> >	return dev->name;
>> >}
>> >EXPORT_SYMBOL(netdev_name);
>
>
>
