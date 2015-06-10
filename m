From: Shrijeet Mukherjee <shm@cumulusnetworks.com>
Subject: Re: [RFC net-next 2/3] VRF driver and needed infrastructure
Date: Tue, 9 Jun 2015 19:11:21 -0700
Message-ID: <CAJmoNQE6_WimdcJMkJzj-0zaHatwsrBKOW6kOMXDHYzwi3F2Vw@mail.gmail.com>
References: <cover.1433561681.git.shm@cumulusnetworks.com>
	<dafc9b784df4cb52691f7dce0f280fc1b2b14532.1433561681.git.shm@cumulusnetworks.com>
	<CABQ03vG0s4w8c5qt_dL7gR9MrnpZmOgtJBy6DkoqgM_8ZT-zVg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	David Ahern <dsahern@gmail.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Jamal Hadi Salim <hadi@mojatatu.com>,
	David Miller <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Netdev <netdev@vger.kernel.org>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Jon Toppins <jtoppins@cumulusnetworks.com>
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:37555 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752289AbbFJCLX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2015 22:11:23 -0400
Received: by wifx6 with SMTP id x6so32317518wif.0
        for <netdev@vger.kernel.org>; Tue, 09 Jun 2015 19:11:22 -0700 (PDT)
In-Reply-To: <CABQ03vG0s4w8c5qt_dL7gR9MrnpZmOgtJBy6DkoqgM_8ZT-zVg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 9, 2015 at 5:35 AM, Nikolay Aleksandrov
<nikolay@cumulusnetworks.com> wrote:
> On Mon, Jun 8, 2015 at 8:35 PM, Shrijeet Mukherjee
> <shm@cumulusnetworks.com> wrote:
>
> vrf_kill_one_slave() calls netdev_rx_handler_unregister() which does
> synchronize_rcu() and
> here you're running with the queue spinlock held and softirqs disabled.
>




>> +
>> +       dev_hold(slave->dev);
>> +       list_add(&slave->list, &queue->all_slaves);
>> +       queue->num_slaves++;
>> +       slave->dev->flags |= IFF_SLAVE;
>> +
>> +       slave->dev->vrf_ptr = kmalloc(sizeof(*slave->dev->vrf_ptr), GFP_KERNEL);
>
> Again this runs with a spinlock and softirqs disabled, GFP_KERNEL can sleep.
>

Good catches, also the one below .. will spin a rev2 patch shortly
with these fixes.

Also working on incorporating Hannes's and Dahern's patches ..


>> +static void vrf_dellink(struct net_device *dev, struct list_head *head)
>> +{
>> +       /* Need to free the table ? */
>> +       unregister_netdev(dev);
>
> I think ->dellink() runs with rtnl held and unregister_netdev() tries
> to acquire rtnl
> so you'll probably deadlock here.
>
>> +}

yup.
