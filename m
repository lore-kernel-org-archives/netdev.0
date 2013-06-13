From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [PATCH RESEND 1/2] neigh: only allow init_net to change the default
 neigh_parms
Date: Thu, 13 Jun 2013 11:44:28 +0800
Message-ID: <51B9401C.1030403@cn.fujitsu.com>
References: <1371012275-31735-1-git-send-email-gaofeng@cn.fujitsu.com> <87ehc7rdel.fsf@xmission.com> <51B91DC0.4010707@cn.fujitsu.com> <87k3lypzpk.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:50281 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S932378Ab3FMDmt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Jun 2013 23:42:49 -0400
In-Reply-To: <87k3lypzpk.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/13/2013 09:27 AM, Eric W. Biederman wrote:
> Gao feng <gaofeng@cn.fujitsu.com> writes:
> 
>> On 06/12/2013 03:33 PM, Eric W. Biederman wrote:
>>> Gao feng <gaofeng@cn.fujitsu.com> writes:
>>>
>>>> Though we don't export the /proc/sys/net/ipv[4,6]/neigh/default/
>>>> directory to the un-init_net, but we can still use cmd such as
>>>> "ip ntable change name arp_cache locktime 129" to change the locktime
>>>> of default neigh_parms.
>>>>
>>>> This patch disallows the un-init_net to find out the neigh_table.parms.
>>>> So the un-init_net will failed to influence the init_net.
>>>
>>> Interesting...  
>>>
>>> The problem these two patches seek to address seems legit.
>>>
>>> However I disagree with the way you are handling this.
>>>
>>> Outside of the initial network namespace we should return -ENOENT
>>> instead of -EPERM.  Which would match how we handle sysctls, and I think
>>> missing neigh table values.  Just not making these global values visible
>>> seems wise.
>>>
>>
>> Ok, it seems more reasonable.
>>
>>> The alternative is to use the proper permission test which is
>>> capable(CAP_SYS_ADMIN) (instead of testing network namespaces) and
>>> return -EPERM if that fails.  Which would allow processes in other
>>> network namespaces to change the value if they could otherwise change
>>> the value.
>>>
>>
>> So you mean the uninitial net namespace can't see these values but it
>> can change them? it's too strange.
> 
> Sorry I was saying that if you don't want to hide the values the
> permissions and (-EPERM) should track the user namespace not the network
> namespace.
> 
>> And the thresh/interval are both under default/ too, if we return -ENOENT
>> for other items, we should also return -ENOENT for them instead of the
>> -EPERM.
> 
> Yes.  Let's return hide the global values and just return -ENOENT for
> everything.  That seems simplest.
> 

Get it, thanks.

BTW, do you think we need to prevent the default parms being leaked to container?
we can use cmd "ip ntable show name arp_cache" get the thresh and so on in container
now.

Thanks!
