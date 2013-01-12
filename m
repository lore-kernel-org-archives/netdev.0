From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH 1/2] tuntap: forbid calling TUNSETIFF when detached
Date: Sat, 12 Jan 2013 10:31:05 +0800
Message-ID: <50F0CAE9.2080303@redhat.com>
References: <1357894242-25020-1-git-send-email-jasowang@redhat.com> <20130111144236.GC2310@stefanha-thinkpad.muc.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Stefan Hajnoczi <stefanha@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130111144236.GC2310@stefanha-thinkpad.muc.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/11/2013 10:42 PM, Stefan Hajnoczi wrote:
> On Fri, Jan 11, 2013 at 04:50:41PM +0800, Jason Wang wrote:
>> @@ -1546,6 +1544,9 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
>>  	struct net_device *dev;
>>  	int err;
>>  
>> +	if (rcu_dereference_protected(tfile->detached, lockdep_rtnl_is_held()))
>> +		return -EINVAL;
>> +
> How come none of the other tfile->detached users call rcu_*()?

Right, no need to use rcu, the access were protected by rtnl lock.

Will repost.
> Stefan
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
