From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH RFC 18/31] net: Implment network device movement between namespaces
Date: Wed, 28 Feb 2007 08:12:16 -0700
Message-ID: <m1fy8qgvu7.fsf@ebiederm.dsl.xmission.com>
References: <m13b5zym0n.fsf@ebiederm.dsl.xmission.com>
	<11697516372179-git-send-email-ebiederm@xmission.com>
	<45E5933D.4070304@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, containers@lists.osdl.org,
	openib-general@openib.org
To: Daniel Lezcano <dlezcano@fr.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:43090 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932979AbXB1PMr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Feb 2007 10:12:47 -0500
In-Reply-To: <45E5933D.4070304@fr.ibm.com> (Daniel Lezcano's message of "Wed,
	28 Feb 2007 15:35:41 +0100")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Daniel Lezcano <dlezcano@fr.ibm.com> writes:

> Eric W. Biederman wrote:
>> From: Eric W. Biederman <ebiederm@xmission.com> - unquoted
>>
>> This patch introduces NETIF_F_NETNS_LOCAL a flag to indicate
>> a network device is local to a single network namespace and
>> should never be moved.  Useful for pseudo devices that we
>> need an instance in each network namespace (like the loopback
>> device) and for any device we find that cannot handle multiple
>> network namespaces so we may trap them in the initial network
>> namespace.
>>
>> This patch introduces the function dev_change_net_namespace
>> a function used to move a network device from one network
>> namespace to another.  To the network device nothing
>> special appears to happen, to the components of the network
>> stack it appears as if the network device was unregistered
>> in the network namespace it is in, and a new device
>> was registered in the network namespace the device
>> was moved to.
>>
>> This patch sets up a namespace device destructor that
>> upon the exit of a network namespace moves all of the
>> movable network devices  to the initial network namespace
>> so they are not lost.
>>
> If you:
> * create etun0/etun1
> * create a namespace
> * move etun1 to this namespace
> *  rename the etun1 to eth0
> *  kill the namespace
>
> the former network device etun1 will be lost if you have in your parent
> namespace an interface eth0 because it will conflict.
> Perhaps, the first name should be restored before moving the device back to the
> initial network namespace ?

Restoration of a previous name is no guarantee of anything.  Someone may have
renamed the some other interface etun1 in the original network namespace.

However if you look closely at the code.  You will discover that if it can't
keep the same name it will rename the device as it switches namespaces.
In particular it will become devN where N is replaced by some unused number.

That is what the pat parameter to dev_change_net_namespace is about.

I'm not exactly thrilled about the generic name but the code should work,
and I don't know if there is a name that makes better sense.


>  -- Daniel
>
> ps : nice patchset

Thanks.

Eric

