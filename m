From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] netns: Coexist with the sysfs limitations
Date: Thu, 23 Oct 2008 08:40:09 -0700
Message-ID: <m1tzb3iali.fsf@frodo.ebiederm.org>
References: <20081022152144.351965414@theryb.frec.bull.fr>
	<m17i80nzff.fsf@frodo.ebiederm.org> <20081022212124.GA9910@us.ibm.com>
	<49003019.40904@bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Serge E. Hallyn" <serue@us.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	Dave Miller <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Al Viro <viro@ftp.linux.org.uk>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	linux-kernel@vger.kernel.org, Tejun Heo <htejun@gmail.com>,
	Denis Lunev <den@openvz.org>,
	Linux Containers <containers@lists.linux-foundation.org>
To: Benjamin Thery <benjamin.thery@bull.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:32899 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752424AbYJWPoh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Oct 2008 11:44:37 -0400
In-Reply-To: <49003019.40904@bull.net> (Benjamin Thery's message of "Thu, 23
	Oct 2008 10:04:41 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Benjamin Thery <benjamin.thery@bull.net> writes:

> Serge E. Hallyn wrote:
>> Quoting Eric W. Biederman (ebiederm@xmission.com):
>>> To make testing of the network namespace simpler allow
>>> the network namespace code and the sysfs code to be
>>> compiled and run at the same time.  To do this only
>>> virtual devices are allowed in the additional network
>>> namespaces and those virtual devices are not placed
>>> in the kobject tree.
>>>
>>> Since virtual devices don't actually do anything interesting
>>> hardware wise that needs device management there should
>>> be no loss in keeping them out of the kobject tree and
>>> by implication sysfs.  The gain in ease of testing
>>> and code coverage should be significant.
>>>
>>> I.e. people running distributions that make it next to
>>> impossible to boot without sysfs should at be able to
>>> boot a test kernel now.
>>>
>>> Plus no ABIs are harmed with this patch.
>
>>> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
>>
>> Duh.
>>
>> Tested-by: Serge Hallyn <serue@us.ibm.com>
>> Acked-by: Serge Hallyn <serue@us.ibm.com>
>
> Oh, this patch is short, clean, and the limitation introduced isn't too
> annoying for testing netns right now.
>
> At least, my proposal provoked some reactions :)

Yes.

> BTW, there's a second limitation with your patch:
> we can't rename the net devices in the additional network namespaces.
>
> In net/core/dev.c, dev_change_name() fails: call to device_rename() return an
> (expected) -EINVAL error.
> Maybe we should add a test on the net to only call it in init_net?

Yes.  Good catch.

Eric
