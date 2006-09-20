From: Joy Latten <latten@austin.ibm.com>
Subject: RE: ipsec acquire has security context although I a m
	not using it.
Date: Wed, 20 Sep 2006 10:16:43 -0500
Message-ID: <200609201516.k8KFGh1I018437@faith.austin.ibm.com>
Cc: redhat-lspp@redhat.com, netdev@vger.kernel.org,
	davem@davemloft.net, selinux@tycho.nsa.gov, jmorris@namei.org
Return-path: <redhat-lspp-bounces@redhat.com>
To: vyekkirala@TrustedCS.com
List-Unsubscribe: <https://www.redhat.com/mailman/listinfo/redhat-lspp>,
	<mailto:redhat-lspp-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/redhat-lspp>
List-Post: <mailto:redhat-lspp@redhat.com>
List-Help: <mailto:redhat-lspp-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/redhat-lspp>,
	<mailto:redhat-lspp-request@redhat.com?subject=subscribe>
Sender: redhat-lspp-bounces@redhat.com
Errors-To: redhat-lspp-bounces@redhat.com
List-Id: netdev.vger.kernel.org

Venkat,

>This doesn't look right since kzalloc would already have zeroed the
>structure out. Are you sure you are getting garbage in the acquire
>from the kernel? If you are, I strongly doubt that this would be the
>one causing it (unless kzalloc on this arch misbehaved).
>Or is this a racoon bug?

Yes, you are correct! Thanks for pointing this out to me
as I missed it! It is racoon that has the bug.
Will fix and post correct fix shortly. Please ignore
attached fix as it is incorrect.

Again, thanks!

Regards,
Joy

>> When using ipsec while selinux is enabled in my kernel, 
>> my racoon daemon fails to establish an SA. I believe the
>> ACQUIRE sent from kernel has a security context although I 
>> am not using this feature with ipsec. As a result, racoon
>> fails to establish the SA, because it is looking for a policy
>> with security context. I noticed the security context 
>> contains garbage. 
>> 
>> I am using a pseries, power5, ppc64 box, and it appears
>> that since policy->security structure is not really initialized
>> or zero'd out when not using, it is possible it may contain garbage
>> on my pseries and a call such as "if (policy->security)" may 
>> come back as true such that security context is included in
>> my acquire message although I believe it should not be. 
>> 
>> Hopefully, the below patch is acceptable. I have compiled and
>> tested it.
>> 
>> Regards,
>> Joy Latten
>> 
>> 
>> diff -urpN linux-2.6.17.orig/net/xfrm/xfrm_policy.c 
>> linux-2.6.17.patch/net/xfrm/xfrm_policy.c
>> --- linux-2.6.17.orig/net/xfrm/xfrm_policy.c	2006-09-19 
>> 02:11:33.000000000 -0500
>> +++ linux-2.6.17.patch/net/xfrm/xfrm_policy.c	2006-09-19 
>> 04:33:50.000000000 -0500
>> @@ -319,6 +319,7 @@ struct xfrm_policy *xfrm_policy_alloc(gf
>>  		init_timer(&policy->timer);
>>  		policy->timer.data = (unsigned long)policy;
>>  		policy->timer.function = xfrm_policy_timer;
>> +		policy->security = NULL;
>>  	}
>>  	return policy;
>>  }
>> 

--
This message was distributed to subscribers of the selinux mailing list.
If you no longer wish to subscribe, send mail to majordomo@tycho.nsa.gov with
the words "unsubscribe selinux" without quotes as the message.
