From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [Intel-wired-lan] [net-next] igb: add function to set I210
 transmit mode
Date: Sat, 13 Aug 2016 12:03:21 -0700
Message-ID: <57AF6EF9.5090707@gmail.com>
References: <1470811692-24574-1-git-send-email-gangfeng.huang@ni.com>
 <1470811692-24574-2-git-send-email-gangfeng.huang@ni.com>
 <CAKgT0UeOmzDaLm0-yuvEjzYoN5g8=ouBv+8rpOmx7MgkWRfA+A@mail.gmail.com>
 <20160813161103.GA1188@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
	intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
	Gangfeng <gangfeng.huang@ni.com>
To: Richard Cochran <richardcochran@gmail.com>,
	Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:35288 "EHLO
	mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751442AbcHNKsn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Aug 2016 06:48:43 -0400
Received: by mail-pf0-f179.google.com with SMTP id x72so9242422pfd.2
        for <netdev@vger.kernel.org>; Sun, 14 Aug 2016 03:48:43 -0700 (PDT)
In-Reply-To: <20160813161103.GA1188@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-08-13 09:11 AM, Richard Cochran wrote:
> On Sat, Aug 13, 2016 at 08:27:38AM -0700, Alexander Duyck wrote:
>> I really don' think this patch is going to work.  If you are going to
>> implement something like this and have a hope to get it accepted into
>> the Linux kernel you need to come up with a solution that will work
>> fore more than this one device.  We don't want the drivers having to
>> carry around their own sysfs controls for things that really are not
>> proprietary to the device.  There needs to be a generic kernel
>> interface for this.  The fact is something like QAV more than likely
>> exists on other devices as well so it may be worth while to look into
>> seeing if you could come up with some way of interfacing this with
>> either ethtool ,iproute2, or maybe even the DCB/LLDP utilities since
>> this is essentially splitting the Tx into two separate traffic
>> classes.
> 
> Yes to all of this.
>  
>> Also for these kind of patches it would be best to include the netdev
>> mailing list.  That way it can be reviewed by a wider audience and you
>> are much more likely to get this accepted upstream rather than have it
>> rejected when Jeff Kirsher attempts to submit it.
> 
> Right.  We just had a discussion about implementing TSN, and we will
> need proper infrastructure in place *before* we start hacking
> drivers.
> 
> Thanks,
> Richard

Ah reading my email backwards. I think we could add TSN under the mqprio
qdisc and ./net/dcb infrastructure. In hindsight I wouldn't have named
the infrastructure dcb as its already being used for other 802.1Q things
and hardware scheduling algorithms that are not strictly DCB.

.John
