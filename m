From: Cong Wang <amwang@redhat.com>
Subject: Re: [net-next PATCH v4 1/3] sysctl: refactor integer handling proc
 code
Date: Tue, 16 Feb 2010 21:08:23 +0800
Message-ID: <4B7A98C7.3070107@redhat.com>
References: <1266271241-6293-1-git-send-email-opurdila@ixiacom.com> <1266271241-6293-2-git-send-email-opurdila@ixiacom.com> <4B7A5A23.3080309@redhat.com> <201002161248.56598.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201002161248.56598.opurdila@ixiacom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Octavian Purdila wrote:
> On Tuesday 16 February 2010 10:41:07 you wrote:
> 
>>> +
>>> +     if (!write && !first && left && !err)
>>> +             err = proc_put_newline(&buffer, &left);
>>> +     if (write && !err)
>>> +             err = proc_skip_wspace(&buffer, &left);
>>> +     if (err == -EFAULT /* do we really need to check for -EFAULT? */ ||
>>> +         (write && first))
>>> +             return err ? : -EINVAL;
>> The logic here seems messy, adding one or two goto's may help?
>>
> 
> OK, I'll give it a try. 
> 
> What about the EFAULT check, is that really required?

I think so, it means to keep the errno to user-space when it is EFAULT,
right? This seems reasonable.
