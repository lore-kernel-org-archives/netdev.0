From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: sysfs^H^H^H^H^Hsysctl warnings, reserved names
Date: Sun, 19 Feb 2012 13:11:41 -0800
Message-ID: <m1aa4e5y0i.fsf@fess.ebiederm.org>
References: <41230e67c273dde6b60cfc7110f496e2@visp.net.lb>
	<1329475042.2861.5.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<1329476631.2861.8.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<m1k43lhdeh.fsf_-_@fess.ebiederm.org>
	<1329483934.2861.12.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Denys Fedoryshchenko <denys@visp.net.lb>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:35559 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755115Ab2BSVIn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Feb 2012 16:08:43 -0500
In-Reply-To: <1329483934.2861.12.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	(Eric Dumazet's message of "Fri, 17 Feb 2012 14:05:34 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> writes:

>> Well we are talking about sysctl not sysfs but same difference, I keep
>> an on eye on them.
>> 
>> I expect renaming a network device to "all" or "default" would be a
>> problem in any kernel supporting renaming of networking devices.
>> 
>> At the basic level of handling it.  sysctl checks for this sometimes
>> now and as soon as my sysctl tree is merged the checks will become
>> unconditionally present.  In what sense were you thinking it would
>> be better to address this in the sysctl?
>> 
>
> Because problem is : it seems a rename() of "eth3" to "default" is
> allowed by sysctl, yet "default" is already in directory.
>
> It seems sysfs_rename_link() / sysfs_rename_dir() / sysfs_rename() might
> have a problem ?

The files are under /proc/sys so we are talking about sysctls, which
means that the error is reported from register_net_sysctl_table.

The path is:
NETDEV_CHANGENAME
	devinet_sysctl_unregister() -> void
	devinet_sysctl_register() -> void
return NOTIFY_DONE;

Eric
