From: Paul Moore <paul@paul-moore.com>
Subject: Re: [RFC PATCH 0/2] selinux: avoid nf hooks overhead when not needed
Date: Wed, 6 Apr 2016 17:43:58 -0400
Message-ID: <CAHC9VhSW7cOjGpf0RA355ytw_s=X+JGZax8G-ZEuF6u4kOeUuw@mail.gmail.com>
References: <cover.1459934322.git.pabeni@redhat.com>
	<5705819A.3030809@schaufler-ca.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Paolo Abeni <pabeni@redhat.com>,
	linux-security-module@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	James Morris <james.l.morris@oracle.com>,
	Andreas Gruenbacher <agruenba@redhat.com>,
	Stephen Smalley <sds@tycho.nsa.gov>,
	Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org
To: Casey Schaufler <casey@schaufler-ca.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f194.google.com ([209.85.214.194]:33005 "EHLO
	mail-ob0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753943AbcDFVn7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2016 17:43:59 -0400
Received: by mail-ob0-f194.google.com with SMTP id js7so2118137obc.0
        for <netdev@vger.kernel.org>; Wed, 06 Apr 2016 14:43:59 -0700 (PDT)
In-Reply-To: <5705819A.3030809@schaufler-ca.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 6, 2016 at 5:37 PM, Casey Schaufler <casey@schaufler-ca.com> wrote:
> On 4/6/2016 2:51 AM, Paolo Abeni wrote:
>> Currently, selinux always registers iptables POSTROUTING hooks regarless of
>> the running policy needs for any action to be performed by them.
>>
>> Even the socket_sock_rcv_skb() is always registered, but it can result in a no-op
>> depending on the current policy configuration.
>>
>> The above invocations in the kernel datapath are cause of measurable
>> overhead in networking performance test.
>>
>> This patch series adds explicit notification for netlabel status change
>> (other relevant status change, like xfrm and secmark, are already notified to
>> LSM) and use this information in selinux to register the above hooks only when
>> the current status makes them relevant, deregistering them when no-op
>>
>> Avoiding the LSM hooks overhead, in netperf UDP_STREAM test with small packets,
>> gives about 5% performance improvement on rx and about 8% on tx.
>>
>> Paolo Abeni (2):
>>   security: add hook for netlabel status change notification
>>   selinux: implement support for dynamic net hook [de-]registration
>>
>>  include/linux/lsm_hooks.h           |  6 ++++
>>  include/linux/security.h            |  5 +++
>>  net/netlabel/netlabel_cipso_v4.c    |  8 +++--
>>  net/netlabel/netlabel_unlabeled.c   |  5 ++-
>>  security/security.c                 |  7 ++++
>>  security/selinux/hooks.c            | 72 +++++++++++++++++++++++++++++++------
>>  security/selinux/include/security.h |  1 +
>>  security/selinux/ss/services.c      |  1 +
>>  security/selinux/xfrm.c             |  4 +++
>>  9 files changed, 96 insertions(+), 13 deletions(-)
>>
>
> Is there a patch 1/2?

Yes, there was (it was the "security: add hook ..." patch), but for
some reason it hasn't hit the archive that I normally use.  Odd.

I'll fwd the patch to you off-list so as not to spam everyone again.

-- 
paul moore
www.paul-moore.com
