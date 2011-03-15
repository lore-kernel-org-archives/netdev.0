From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] ipv4: netfilter: ipt_CLUSTERIP: fix buffer overflow
Date: Tue, 15 Mar 2011 13:33:48 +0100
Message-ID: <4D7F5CAC.6070006@trash.net>
References: <1299780740-32652-1-git-send-email-segoon@openwall.com> <AANLkTimPZJoCzz386e-4m0Y4khWGZirZguGFmuFYCrry@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Vasiliy Kulikov <segoon@openwall.com>,
	linux-kernel@vger.kernel.org, security@kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <AANLkTimPZJoCzz386e-4m0Y4khWGZirZguGFmuFYCrry@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 13.03.2011 15:00, Changli Gao wrote:
> On Fri, Mar 11, 2011 at 2:12 AM, Vasiliy Kulikov <segoon@openwall.com> wrote:
>> buffer string is copied from userspace.  It is not checked whether it is
>> zero terminated.  This may lead to overflow inside of simple_strtoul().
>>
>> It was introduced before the git epoch.  Files "ipt_CLUSTERIP/*" are
>> root writable only by default, however, on some setups permissions might be
>> relaxed to e.g. network admin user.
>>
>> Signed-off-by: Vasiliy Kulikov <segoon@openwall.com>
>> ---
>>  Compile tested.
>>
>>  net/ipv4/netfilter/ipt_CLUSTERIP.c |    1 +
>>  1 files changed, 1 insertions(+), 0 deletions(-)
>>
>> diff --git a/net/ipv4/netfilter/ipt_CLUSTERIP.c b/net/ipv4/netfilter/ipt_CLUSTERIP.c
>> index 403ca57..7aabf9a 100644
>> --- a/net/ipv4/netfilter/ipt_CLUSTERIP.c
>> +++ b/net/ipv4/netfilter/ipt_CLUSTERIP.c
>> @@ -666,6 +666,7 @@ static ssize_t clusterip_proc_write(struct file *file, const char __user *input,
>>
>>        if (copy_from_user(buffer, input, PROC_WRITELEN))
> 
> I think size should be used instead of PROC_WRITELEN.
> 
> if (size > PROC_WRITELEN)
>      return -EIO;
> if (copy_from_user(buffer, input, size))
>     return -EFAULT;
> buffer[size] = '\0';

I agree, otherwise we might have the situation that the userspace
copy is crossing page boundaries into unmapped memory.



