From: Ross Lagerwall <ross.lagerwall@citrix.com>
Subject: Re: [PATCH] xen-netfront: Improve error handling during
 initialization
Date: Thu, 2 Feb 2017 14:54:31 +0000
Message-ID: <bbe85105-f5aa-79ea-6eab-0cfaea28555a@citrix.com>
References: <1485964222-1501-1-git-send-email-ross.lagerwall@citrix.com>
 <78bd8aab-69db-30cb-45ac-d12e17870447@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>,
        Juergen Gross <jgross@suse.com>,
        <linux-kernel@vger.kernel.org>, <wei.liu2@citrix.com>
To: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <78bd8aab-69db-30cb-45ac-d12e17870447@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/01/2017 06:54 PM, Boris Ostrovsky wrote:
> On 02/01/2017 10:50 AM, Ross Lagerwall wrote:
>> Improve error handling during initialization. This fixes a crash when
>> running out of grant refs when creating many queues across many netdevs.
>>
>> * Delay timer creation so that if initializing a queue fails, the timer
>> has not been setup yet.
>> * If creating queues fails (i.e. there are no grant refs available),
>> call xenbus_dev_fatal() to ensure that the xenbus device is set to the
>> closed state.
>> * If no queues are created, don't call xennet_disconnect_backend as
>> netdev->real_num_tx_queues will not have been set correctly.
>> * If setup_netfront() fails, ensure that all the queues created are
>> cleaned up, not just those that have been set up.
>> * If any queues were set up and an error occurs, call
>> xennet_destroy_queues() to stop the timer and clean up the napi context.
>
> We need to stop the timer in xennet_disconnect_backend(). I sent a patch
> a couple of day ago
>
> https://lists.xenproject.org/archives/html/xen-devel/2017-01/msg03269.html
>
> but was about to resend it with del_timer_sync() moved after
> napi_synchronize().
>

OK, but the patch is still relevant since I believe we still need to 
clean up the napi context in this case (plus the patch fixes a lot of 
other issues).

But I will respin it on top of your patch(es) and re-test it before 
resending.

-- 
Ross Lagerwall
