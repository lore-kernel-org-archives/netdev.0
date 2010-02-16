From: Cong Wang <amwang@redhat.com>
Subject: Re: [net-next PATCH v4 1/3] sysctl: refactor integer handling proc
 code
Date: Tue, 16 Feb 2010 21:09:51 +0800
Message-ID: <4B7A991F.3040601@redhat.com>
References: <1266271241-6293-1-git-send-email-opurdila@ixiacom.com> <1266271241-6293-2-git-send-email-opurdila@ixiacom.com> <4B7A5A23.3080309@redhat.com> <201002161341.56206.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:24542 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755635Ab0BPNG0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Feb 2010 08:06:26 -0500
In-Reply-To: <201002161341.56206.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Octavian Purdila wrote:
> On Tuesday 16 February 2010 10:41:07 you wrote:
> 
>>> +static int proc_skip_wspace(char __user **buf, size_t *size)
>>> +{
>>> +     char c;
>>> +
>>> +     while (*size) {
>>> +             if (get_user(c, *buf))
>>> +                     return -EFAULT;
>>> +             if (!isspace(c))
>>> +                     break;
>>> +             (*size)--; (*buf)++;
>>> +     }
>>> +
>>> +     return 0;
>>> +}
>> In lib/string.c we have skip_spaces(), I think we can use it
>> here instead of inventing another one.
>>
> 
> I'm afraid we can't, skip_spaces does not accept userspace buffers.

Well, you need to use copy_from_user() before call it.

