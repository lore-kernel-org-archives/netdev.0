From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: ovs: flow: fix potential illegal memory
 access in __parse_flow_nlattrs
Date: Wed, 11 Sep 2013 16:14:42 -0400 (EDT)
Message-ID: <20130911.161442.1309302931442181150.davem@davemloft.net>
References: <1378539694-3635-1-git-send-email-dborkman@redhat.com>
	<CAEP_g=_Bgt8OsORTyYRt=tbssfbd-0Jh2HhnjPdj1aVP8Zd1BA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dborkman@redhat.com, netdev@vger.kernel.org, azhou@nicira.com,
	dev@openvswitch.org
To: jesse@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46839 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755749Ab3IKUOo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Sep 2013 16:14:44 -0400
In-Reply-To: <CAEP_g=_Bgt8OsORTyYRt=tbssfbd-0Jh2HhnjPdj1aVP8Zd1BA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Gross <jesse@nicira.com>
Date: Sat, 7 Sep 2013 22:35:33 -0700

> On Sat, Sep 7, 2013 at 12:41 AM, Daniel Borkmann <dborkman@redhat.com> wrote:
>> In function __parse_flow_nlattrs(), we check for condition
>> (type > OVS_KEY_ATTR_MAX) and if true, print an error, but we do
>> not return from this function as in other checks. It seems this
>> has been forgotten, as otherwise, we could access beyond the
>> memory of ovs_key_lens, which is of ovs_key_lens[OVS_KEY_ATTR_MAX + 1].
>> Hence, a maliciously prepared nla_type from user space could access
>> beyond this upper limit.
>>
>> Introduced by 03f0d916a ("openvswitch: Mega flow implementation").
>>
>> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
>> Cc: Andy Zhou <azhou@nicira.com>
> 
> Yeah, looks like a mistake to me.
> 
> Acked-by: Jesse Gross <jesse@nicira.com>

Applied, thanks.
