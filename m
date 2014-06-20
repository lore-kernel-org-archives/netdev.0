From: Andy Green <andy.green@linaro.org>
Subject: Re: [net-next PATCH 2] net: ethernet driver: Fujitsu OGMA
Date: Fri, 20 Jun 2014 15:10:08 +0800
Message-ID: <CAAfg0W6NX0cFpfR0NEqcc3BJGRFGskZWV4M8XhyuqnjcU=2FDQ@mail.gmail.com>
References: <20140610010803.18695.88446.stgit@localhost.localdomain>
	<20140610102834.450effd6@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Patch Tracking <patches@linaro.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f179.google.com ([209.85.216.179]:42075 "EHLO
	mail-qc0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752794AbaFTHKJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jun 2014 03:10:09 -0400
Received: by mail-qc0-f179.google.com with SMTP id x3so3198071qcv.10
        for <netdev@vger.kernel.org>; Fri, 20 Jun 2014 00:10:08 -0700 (PDT)
In-Reply-To: <20140610102834.450effd6@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11 June 2014 01:28, Stephen Hemminger <stephen@networkplumber.org> wrote:
> On Tue, 10 Jun 2014 09:08:03 +0800
> Andy Green <andy.green@linaro.org> wrote:
>
>> +static int ogma_netdev_change_mtu(struct net_device *net_device, int new_mtu)
>> +{
>> +     struct ogma_ndev *ndev = netdev_priv(net_device);
>> +
>> +     if (!ndev->priv->param.use_jumbo_pkt_flag)
>> +             return eth_change_mtu(net_device, new_mtu);
>> +
>> +     if ((new_mtu < 68) || (new_mtu > 9000))
>> +             return -EINVAL;
>> +
>> +     net_device->mtu = new_mtu;
>> +
>> +     return 0;
>> +}
>> +
>
> I don't think this works. rx_pkt_buf_len is only set at probe time.
>
> Don't you need to:
>  1. Stop device if running
>  2. Free existing receive buffers
>  3. change rx_pkt_buf_len
>  4. Refill restart receiver.
>
> Most devices setup receive ring in open (not probe)
> to handle this. It also avoid grabbing memory if device is unused.

Sorry for the late response... I have just sent v4 implementing all
the comments except perhaps this one.

I understand the issue you mention.  I have indeed now moved the rx
buffer alloc / free into the network_device open / close.

But it wasn't clear to me from your comment that if we do that, that
the networking stack itself will take care about close and reopen the
network device on mtu change.

If that's the case I guess I can use eth_change_mtu now, but is that
what you meant by "Most devices setup receive ring in open (not probe)
 to handle this"?

-Andy
