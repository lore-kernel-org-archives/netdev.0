From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 13/16] net: Introduce VRF device driver - v2
Date: Tue, 28 Jul 2015 10:22:11 -0600
Message-ID: <55B7AC33.1000506@cumulusnetworks.com>
References: <1438021869-49186-1-git-send-email-dsa@cumulusnetworks.com> <1438021869-49186-14-git-send-email-dsa@cumulusnetworks.com> <55B68E16.1020309@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shm@cumulusnetworks.com, roopa@cumulusnetworks.com,
	gospo@cumulusnetworks.com, jtoppins@cumulusnetworks.com,
	ddutt@cumulusnetworks.com, hannes@stressinduktion.org,
	nicolas.dichtel@6wind.com, stephen@networkplumber.org,
	hadi@mojatatu.com, ebiederm@xmission.com, davem@davemloft.net,
	svaidya@brocade.com, mingo@kernel.org, luto@amacapital.net
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:35909 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751985AbbG1QWO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2015 12:22:14 -0400
Received: by pdjr16 with SMTP id r16so74510671pdj.3
        for <netdev@vger.kernel.org>; Tue, 28 Jul 2015 09:22:13 -0700 (PDT)
In-Reply-To: <55B68E16.1020309@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/27/15 2:01 PM, Nikolay Aleksandrov wrote:
>> +
>> +	if (!vrf_is_master(dev) || vrf_is_master(port_dev) ||
>
> Hmm, this means that bonds won't be able to be VRF slaves.
> They have the IFF_MASTER flag set.

Right, will change to the IFF_VRF_MASTER flag.

>
>> +	    vrf_is_slave(port_dev))
>> +		return -EINVAL;
>> +
>> +	return do_vrf_add_slave(dev, port_dev);
>> +}
>> +
>> +/* inverse of do_vrf_add_slave */
>> +static int do_vrf_del_slave(struct net_device *dev, struct net_device *port_dev)
>> +{
>> +	struct net_vrf *vrf = netdev_priv(dev);
>> +	struct slave_queue *queue = &vrf->queue;
>> +	struct net_vrf_dev *vrf_ptr = NULL;
>> +	struct slave *slave;
>> +
>> +	vrf_ptr = rcu_dereference(dev->vrf_ptr);
>> +	RCU_INIT_POINTER(dev->vrf_ptr, NULL);
>
> I think this isn't safe, you should wait for a grace period before freeing the
> pointer. Actually you can just move the kfree() below the netdev_rx_handler_unregister()
> since it does synchronize_rcu() anyway.

ok

And ack on all other comments..

Thanks for the review,
David
