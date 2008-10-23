From: Benjamin Thery <benjamin.thery@bull.net>
Subject: Re: [PATCH] netns: Coexist with the sysfs limitations
Date: Thu, 23 Oct 2008 10:04:41 +0200
Message-ID: <49003019.40904@bull.net>
References: <20081022152144.351965414@theryb.frec.bull.fr> <m17i80nzff.fsf@frodo.ebiederm.org> <20081022212124.GA9910@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Serge E. Hallyn" <serue@us.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	Dave Miller <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Al Viro <viro@ftp.linux.org.uk>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	linux-kernel@vger.kernel.org, Tejun Heo <htejun@gmail.com>,
	Denis Lunev <den@openvz.org>,
	Linux Containers <containers@lists.linux-foundation.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:60995 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751826AbYJWJC5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Oct 2008 05:02:57 -0400
In-Reply-To: <20081022212124.GA9910@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Serge E. Hallyn wrote:
> Quoting Eric W. Biederman (ebiederm@xmission.com):
>> To make testing of the network namespace simpler allow
>> the network namespace code and the sysfs code to be
>> compiled and run at the same time.  To do this only
>> virtual devices are allowed in the additional network
>> namespaces and those virtual devices are not placed
>> in the kobject tree.
>>
>> Since virtual devices don't actually do anything interesting
>> hardware wise that needs device management there should
>> be no loss in keeping them out of the kobject tree and
>> by implication sysfs.  The gain in ease of testing
>> and code coverage should be significant.
>>
>> I.e. people running distributions that make it next to
>> impossible to boot without sysfs should at be able to
>> boot a test kernel now.
>>
>> Plus no ABIs are harmed with this patch.

>> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
> 
> Duh.
> 
> Tested-by: Serge Hallyn <serue@us.ibm.com>
> Acked-by: Serge Hallyn <serue@us.ibm.com>

Oh, this patch is short, clean, and the limitation introduced isn't too
annoying for testing netns right now.

At least, my proposal provoked some reactions :)

BTW, there's a second limitation with your patch:
we can't rename the net devices in the additional network namespaces.

In net/core/dev.c, dev_change_name() fails: call to device_rename() 
return an (expected) -EINVAL error.
Maybe we should add a test on the net to only call it in init_net?

  rollback:
-       err = device_rename(&dev->dev, dev->name);
-       if (err) {
-               memcpy(dev->name, oldname, IFNAMSIZ);
-               return err;
+       if (net == &init_net) {
+               err = device_rename(&dev->dev, dev->name);
+               if (err) {
+                       memcpy(dev->name, oldname, IFNAMSIZ);
+                       return err;
+               }
         }

Otherwise,

Acked-by: Benjamin Thery <benjamin.thery@bull.net>

Thanks,
Benjamin

> 
> Thanks, Eric!  Thanks, Benjamin!
> 
> -serge
> 
> 


-- 
B e n j a m i n   T h e r y  - BULL/DT/Open Software R&D

    http://www.bull.com
