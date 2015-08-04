From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next v2 1/2] openvswitch: Use regular GRE net_device
 instead of vport
Date: Mon, 3 Aug 2015 22:58:02 -0700
Message-ID: <CALnjE+ruRdOhs1=E1ZRyPdhoKFr08yqZJvh3Z21wE-yjRgg4hQ@mail.gmail.com>
References: <1438648046-10346-1-git-send-email-pshelar@nicira.com>
	<20150804042339.GA47032@Alexeis-MBP.westell.com>
	<CALnjE+q-sBLWE5WPY451YYG8zv9g2E00aKkRHGo1cDf+xGAGnA@mail.gmail.com>
	<20150804055359.GA47320@Alexeis-MBP.westell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:33900 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750996AbbHDF6D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2015 01:58:03 -0400
Received: by igk11 with SMTP id 11so86262838igk.1
        for <netdev@vger.kernel.org>; Mon, 03 Aug 2015 22:58:02 -0700 (PDT)
In-Reply-To: <20150804055359.GA47320@Alexeis-MBP.westell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 3, 2015 at 10:54 PM, Alexei Starovoitov
<alexei.starovoitov@gmail.com> wrote:
> On Mon, Aug 03, 2015 at 10:51:02PM -0700, Pravin Shelar wrote:
>> On Mon, Aug 3, 2015 at 9:23 PM, Alexei Starovoitov
>> <alexei.starovoitov@gmail.com> wrote:
>> > On Mon, Aug 03, 2015 at 05:27:26PM -0700, Pravin B Shelar wrote:
>> >> With addition of flow based tunneling, there is no need to
>> >> have special GRE vport. Removes all of the OVS specific
>> >> GRE code and make OVS use a ip_gre net_device.
>> >> Minimal GRE vport is kept to handle compatibility with
>> >> current userspace application.
>> >>
>> >> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
>> > ...
>> >> +#define GRE_TAP_FB_NAME "gretap0"
>> > ...
>> >> +     /* fallback device is used for flow based tunneling. */
>> >> +     if (!strcmp(dev->name, GRE_TAP_FB_NAME)) {
>> >> +             struct ip_tunnel *t;
>> >> +
>> >> +             t = netdev_priv(dev);
>> >> +             t->flow_based_tunnel = true;
>> >> +             eth_hw_addr_random(dev);
>> >> +             netif_keep_dst(dev);
>> >> +     }
>> >> +
>> >
>> > feature detection based on netdev name?
>> > meaning that there will be only one such device for the whole
>> > host? and namespaces cannot have their own gre tunnels?
>> > (since host 'gretap0' cannot be seen in netns)
>> >
>> gretap0 exist in every namespace. This device is created in GRE namespce init.
>
> then all of them get to be in flow_based mode without being able to
> change it?
>
Yes, But there is no side effect of this feature for the user of the device.
