From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [Intel-wired-lan] [net-next] igb: add function to set I210
 transmit mode
Date: Sat, 13 Aug 2016 12:01:12 -0700
Message-ID: <57AF6E78.6030800@gmail.com>
References: <1470811692-24574-1-git-send-email-gangfeng.huang@ni.com>
 <1470811692-24574-2-git-send-email-gangfeng.huang@ni.com>
 <CAKgT0UeOmzDaLm0-yuvEjzYoN5g8=ouBv+8rpOmx7MgkWRfA+A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: intel-wired-lan <intel-wired-lan@lists.osuosl.org>
To: Alexander Duyck <alexander.duyck@gmail.com>,
	Gangfeng <gangfeng.huang@ni.com>, Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:33600 "EHLO
	mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750905AbcHNI3k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Aug 2016 04:29:40 -0400
Received: by mail-pf0-f172.google.com with SMTP id y134so8733834pfg.0
        for <netdev@vger.kernel.org>; Sun, 14 Aug 2016 01:29:39 -0700 (PDT)
In-Reply-To: <CAKgT0UeOmzDaLm0-yuvEjzYoN5g8=ouBv+8rpOmx7MgkWRfA+A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-08-13 08:27 AM, Alexander Duyck wrote:
> On Tue, Aug 9, 2016 at 11:48 PM, Gangfeng <gangfeng.huang@ni.com> wrote:
>> From: Gangfeng Huang <gangfeng.huang@ni.com>
>>
>> I210 supports two transmit modes, legacy and Qav. The transmit mode is
>> configured in TQAVCTRL.QavMode register. Before this patch igb driver
>> only support legacy mode. This patch makes it possible to configure the
>> transmit mode.
>>
>> Example:
>> Get the transmit mode:
>> $ echo /sys/class/net/eth0/qav_mode
>> 0
>> Set transmit mode to qav mode
>> $ echo 1 > /sys/class/net/eth0/qav_mode
>>
>> Tested:
>> Setting /sys/class/net/eth0/qav_mode to Qav mode,
>>  1) Switch back and forth between Qav mode and legacy mode
>>  2) Send/recv packets in both mode.
>>
>> Signed-off-by: Gangfeng Huang <gangfeng.huang@ni.com>
> 
> I really don' think this patch is going to work.  If you are going to
> implement something like this and have a hope to get it accepted into
> the Linux kernel you need to come up with a solution that will work
> fore more than this one device.  We don't want the drivers having to
> carry around their own sysfs controls for things that really are not
> proprietary to the device.  There needs to be a generic kernel
> interface for this.  The fact is something like QAV more than likely
> exists on other devices as well so it may be worth while to look into
> seeing if you could come up with some way of interfacing this with
> either ethtool ,iproute2, or maybe even the DCB/LLDP utilities since
> this is essentially splitting the Tx into two separate traffic
> classes.
> 
> Also for these kind of patches it would be best to include the netdev
> mailing list.  That way it can be reviewed by a wider audience and you
> are much more likely to get this accepted upstream rather than have it
> rejected when Jeff Kirsher attempts to submit it.
> 


Take a look at ./net/sched/sch_mqprio.c and the ndo op setup_tc.
Multiple folks have been talking about adding support for this and
I think a lot of the bits you need might be there.

.John
