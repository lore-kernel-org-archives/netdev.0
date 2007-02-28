From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH RFC 22/31] net: Add network namespace clone support.
Date: Wed, 28 Feb 2007 08:05:13 -0700
Message-ID: <m1k5y2gw5y.fsf@ebiederm.dsl.xmission.com>
References: <m13b5zym0n.fsf@ebiederm.dsl.xmission.com>
	<11697516373288-git-send-email-ebiederm@xmission.com>
	<45E594C0.6090009@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, containers@lists.osdl.org,
	openib-general@openib.org
To: Daniel Lezcano <dlezcano@fr.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:42074 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932478AbXB1PF7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Feb 2007 10:05:59 -0500
In-Reply-To: <45E594C0.6090009@fr.ibm.com> (Daniel Lezcano's message of "Wed,
	28 Feb 2007 15:42:08 +0100")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Daniel Lezcano <dlezcano@fr.ibm.com> writes:


>> +
>> +	mutex_lock(&net_mutex);
>> +	err = setup_net(new_net);
>> +	if (err)
>> +		goto out_unlock;
>>
> Should we "net_free" in case of error ?

Oops.  Yes we should.
Thanks.

>> +	net_lock();
>> +	net_list_append(new_net);
>> +	net_unlock();
>> +
>> +	tsk->nsproxy->net_ns = new_net;
>> +
>> +out_unlock:
>> +	mutex_unlock(&net_mutex);
	net_free(new_net);
>> +out:
>> +	put_net(old_net);
>> +	return err;
>> +}
>> +
>>

Eric
