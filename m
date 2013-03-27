From: dingtianhong <dingtianhong@huawei.com>
Subject: [PATCH] af_unix: dont send SCM_CREDENTIAL when dest socket is NULL
Date: Wed, 27 Mar 2013 15:35:52 +0800
Message-ID: <5152A158.3030401@huawei.com>
References: <515026DA.7050306@huawei.com>   <1364220269.29473.13.camel@edumazet-glaptop> <51511148.4000804@huawei.com>  <1364272360.1716.11.camel@edumazet-glaptop> <515187F6.4030905@huawei.com> <1364305597.1716.13.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>, <netdev@vger.kernel.org>,
	Li Zefan <lizefan@huawei.com>, Xinwei Hu <huxinwei@huawei.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:22724 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752706Ab3C0HgR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Mar 2013 03:36:17 -0400
In-Reply-To: <1364305597.1716.13.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/3/26 21:46, Eric Dumazet wrote:
> On Tue, 2013-03-26 at 19:35 +0800, dingtianhong wrote:
> 
>> I think if not call scm_set_creds(), the credential would useles in recvmsg().
>> we could remove code:
>> 		if (check_creds) {
>>                         /* Never glue messages from different writers */
>>                         if ((UNIXCB(skb).pid  != siocb->scm->pid) ||
>>                             (UNIXCB(skb).cred != siocb->scm->cred))
>>                                 break;
>>                 } else {
>>                         /* Copy credentials */
>>                         scm_set_cred(siocb->scm, UNIXCB(skb).pid, UNIXCB(skb).cred);
>>                         check_creds = 1;
>>                 }
> 
> Are you paraphrasing me or saying something different ?
>  

if not call scm_set_creds(), how get credentials for receiver and distinguish different writes,
so I think scm_set_creds() is necessary here.

> 
> 
> 
