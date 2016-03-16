From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next v3 1/2] RDS: TCP: Add sysctl tunables for
 sndbuf/rcvbuf on rds-tcp socket
Date: Wed, 16 Mar 2016 12:26:40 +0100
Message-ID: <56E942F0.90201@stressinduktion.org>
References: <cover.1458064902.git.sowmini.varadhan@oracle.com>
 <5c18f6bdde99628e486d63a071c256d1be036c28.1458064902.git.sowmini.varadhan@oracle.com>
 <56E93596.90503@stressinduktion.org> <20160316111055.GB21307@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	santosh.shilimkar@oracle.com, eric.dumazet@gmail.com
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:56896 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S965917AbcCPL0m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2016 07:26:42 -0400
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by mailout.nyi.internal (Postfix) with ESMTP id 00955204E9
	for <netdev@vger.kernel.org>; Wed, 16 Mar 2016 07:26:41 -0400 (EDT)
In-Reply-To: <20160316111055.GB21307@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16.03.2016 12:10, Sowmini Varadhan wrote:
> On (03/16/16 11:29), Hannes Frederic Sowa wrote:
>> Normally we kmemdup a table per netns and update its data pointer,
>> so we can reuse the proc_doint_minmax functions.
>
> I remembered one more thing.. in this particular case, I need to
> have my one ->proc_handler, because I need to rds_tcp_sysctl_reset()
> existing connections to make them use the new tunable.

My hope was actually that by using the ->data pointer in netns you don't 
need to provide the two functions, just simply use something like the 
following for both cases.

static int rds_skbuf_handler(...) {
	int err;

	err = proc_dointvec(...);
	if (err)
		return err;

	if (write)
		rds_tcp_sysctl_reset(...);

	return err;
}

If you use proc_dointvec_min(max) you can already sanitize the input 
values even more.

Do I understand it correctly that all connections of a namespace will be 
dropped if you modify those sysctls?

Thanks,
Hannes
