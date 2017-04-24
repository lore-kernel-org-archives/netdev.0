From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH 1/2] ixgbe: add XDP support for pass and drop actions
Date: Sun, 23 Apr 2017 21:26:26 -0700
Message-ID: <58FD7E72.6010907@gmail.com>
References: <20170424013004.8354.34893.stgit@john-Precision-Tower-5810>
 <20170424013119.8354.18750.stgit@john-Precision-Tower-5810>
 <20170423210506.79168335@laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org
To: Jakub Kicinski <kubakici@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:33343 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750744AbdDXE0h (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 00:26:37 -0400
Received: by mail-io0-f194.google.com with SMTP id k87so45004660ioi.0
        for <netdev@vger.kernel.org>; Sun, 23 Apr 2017 21:26:37 -0700 (PDT)
In-Reply-To: <20170423210506.79168335@laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-04-23 09:05 PM, Jakub Kicinski wrote:
> Hi!
> 
> On Sun, 23 Apr 2017 18:31:19 -0700, John Fastabend wrote:
>> +static int ixgbe_xdp_setup(struct net_device *dev, struct bpf_prog *prog)
>> +{
>> +	int i, frame_size = dev->mtu + ETH_HLEN + ETH_FCS_LEN + VLAN_HLEN;
>> +	struct ixgbe_adapter *adapter = netdev_priv(dev);
>> +	struct bpf_prog *old_prog;
>> +
>> +	if (adapter->flags & IXGBE_FLAG_SRIOV_ENABLED)
>> +		return -EINVAL;
>> +
>> +	if (adapter->flags & IXGBE_FLAG_DCB_ENABLED)
>> +		return -EINVAL;
>> +
>> +	/* verify ixgbe ring attributes are sufficient for XDP */
>> +	for (i = 0; i < adapter->num_rx_queues; i++) {
>> +		struct ixgbe_ring *ring = adapter->rx_ring[i];
>> +
>> +		if (ring_is_rsc_enabled(ring))
>> +			return -EINVAL;
>> +
>> +		if (frame_size > ixgbe_rx_bufsz(ring))
>> +			return -EINVAL;
>> +	}
> 
> I was just looking through the drivers, working on extended ack
> reporting, trying to bring out the driver XDP error messages out
> directly to iproute2.  It seems that multiple drivers are only 
> checking that MTU/buffer size is appropriate in the XDP_SETUP 
> function, and ignore XDP in case user tries to change MTU later.  
> And I think it's the same story with LRO?
> 

Agreed we need to harden the drivers to changes post XDP init. I'll submit
a few follow on patches for the ixgbe devices in the morning.

Thanks,
John
