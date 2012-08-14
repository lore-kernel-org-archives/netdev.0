From: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
Subject: Re: [patch net-next 03/16] vlan: add link to upper device
Date: Tue, 14 Aug 2012 09:24:27 +0200
Message-ID: <20120814072427.GA1767@minipsycho.orion>
References: <1344871635-1052-1-git-send-email-jiri@resnulli.us>
 <1344871635-1052-4-git-send-email-jiri@resnulli.us>
 <20120813160421.77a74e4e@obelix.rh>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
	faisal.latif-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, fubar-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org,
	divy-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, jitendra.kalsaria-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org,
	sony.chacko-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org, linux-driver-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org,
	ursula.braun-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org, blaschka-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org,
	linux390-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org, shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org,
	bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org, therbert-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
	xiyou.wangcong-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org,
	gregory.v.rose-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bridge-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Flavio Leitner <fbl-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120813160421.77a74e4e-8Luz0qD3JK/tRgLqZ5aouw@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Mon, Aug 13, 2012 at 09:04:21PM CEST, fbl-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org wrote:
>On Mon, 13 Aug 2012 17:27:02 +0200
>Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org> wrote:
>
>> Signed-off-by: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
>> ---
>>  net/8021q/vlan.c |   10 +++++++++-
>>  1 file changed, 9 insertions(+), 1 deletion(-)
>> 
>> diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
>> index 9096bcb..739665e 100644
>> --- a/net/8021q/vlan.c
>> +++ b/net/8021q/vlan.c
>> @@ -105,6 +105,8 @@ void unregister_vlan_dev(struct net_device *dev, struct list_head *head)
>>  	 */
>>  	unregister_netdevice_queue(dev, head);
>>  
>> +	netdev_upper_dev_unlink(real_dev, dev);
>> +
>>  	if (grp->nr_vlan_devs == 0)
>>  		vlan_gvrp_uninit_applicant(real_dev);
>>  
>> @@ -162,9 +164,13 @@ int register_vlan_dev(struct net_device *dev)
>>  	if (err < 0)
>>  		goto out_uninit_applicant;
>>  
>> +	err = netdev_upper_dev_link(real_dev, dev);
>> +	if (err)
>> +		goto out_uninit_applicant;
>> +
>>  	err = register_netdevice(dev);
>>  	if (err < 0)
>> -		goto out_uninit_applicant;
>> +		goto out_upper_dev_unlink;
>                ^^^^^^^^^^^^^^^^^^^^^^^^^^^
>see below:
>
>>  
>>  	/* Account for reference in struct vlan_dev_priv */
>>  	dev_hold(real_dev);
>> @@ -180,6 +186,8 @@ int register_vlan_dev(struct net_device *dev)
>>  
>>  	return 0;
>>  
>> +upper_dev_unlink:
>^^^^^^^^^^^^^^^^^^^
>should be out_upper_dev_unlink:

fixed.

Thanks!

>
>fbl
>
>> +	netdev_upper_dev_unlink(real_dev, dev);
>>  out_uninit_applicant:
>>  	if (grp->nr_vlan_devs == 0)
>>  		vlan_gvrp_uninit_applicant(real_dev);
>
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
