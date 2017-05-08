From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: Re: [PATCH v4 net-next 04/10] net/ncsi: Ethtool operation to get
 NCSI topology
Date: Mon, 8 May 2017 10:19:55 +1000
Message-ID: <20170508001955.GA5787@gwshan>
References: <1493786681-27468-1-git-send-email-gwshan@linux.vnet.ibm.com>
 <1493786681-27468-5-git-send-email-gwshan@linux.vnet.ibm.com>
 <20170503221944.1dd0d576@xeon-e3>
 <20170504061559.GA2162@gwshan>
 <063D6719AE5E284EB5DD2968C1650D6DCFFE535E@AcuExch.aculab.com>
Reply-To: Gavin Shan <gwshan@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "'Gavin Shan'" <gwshan@linux.vnet.ibm.com>,
        Stephen Hemminger <stephen@networkplumber.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "joe@perches.com" <joe@perches.com>,
        "kubakici@wp.pl" <kubakici@wp.pl>,
        "f.fainelli@gmail.com" <f.fainelli@gmail.com>,
        "davem@davemloft.net" <davem@davemloft.net>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:49685 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1750782AbdEHAU7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 7 May 2017 20:20:59 -0400
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v4803Zrv001409
        for <netdev@vger.kernel.org>; Sun, 7 May 2017 20:20:58 -0400
Received: from e23smtp08.au.ibm.com (e23smtp08.au.ibm.com [202.81.31.141])
        by mx0b-001b2d01.pphosted.com with ESMTP id 2aad7p9k9n-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Sun, 07 May 2017 20:20:58 -0400
Received: from localhost
        by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
        Mon, 8 May 2017 10:20:56 +1000
Received: from d23av06.au.ibm.com (d23av06.au.ibm.com [9.190.235.151])
        by d23relay09.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v480KjFe16187638
        for <netdev@vger.kernel.org>; Mon, 8 May 2017 10:20:53 +1000
Received: from d23av06.au.ibm.com (localhost [127.0.0.1])
        by d23av06.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v480KK6F024611
        for <netdev@vger.kernel.org>; Mon, 8 May 2017 10:20:21 +1000
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DCFFE535E@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 04, 2017 at 09:31:20AM +0000, David Laight wrote:
>From: Gavin Shan
>> Sent: 04 May 2017 07:16
>> On Wed, May 03, 2017 at 10:19:44PM -0700, Stephen Hemminger wrote:
>> >On Wed,  3 May 2017 14:44:35 +1000
>> >Gavin Shan <gwshan@linux.vnet.ibm.com> wrote:
>...
>> >> +{
>> >> +	struct ethtool_ncsi_channels *enc;
>> >> +	short nr_channels;
>> >Should be __u16 or unsigned not short.
>> >
>> 
>> Nope, It's for signed number. User expects to get number of available
>> channels when negative number is passed in. When it's positive, it's
>> going to get the channels' information.
>
>Why 16 bits?
>You are just making life hard for the compiler and possibly generating
>random padding.
>

It's because there are 256 NCSI channels to maximal degree. So 16-bits
is the minial data width to hold it in signed format. Yes, I think
__s32 would be better in this case. However, I would like to discard
the negotiation mechanism in next respin.

>I guess the user is expected to pass -1 first to get the number of
>channels, then allocate an appropriate sized array and call again
>specifying the number of channels?
>

It's correct.

>What happens if the number of channels changes between the two requests?
>

There are only one case the number changes from zero to x. In previous call,
zero is returned and userspace will get nothing. When x channels are probed,
it's stable and won't change. I don't see any problem because of it.

In next respin, I'll pass 256 entries directly. Each entry will have a flag
to indicate it's valid or not. No negotiation will be needed.

>I'd also suggest passing the size of each entry (in at least one direction).
>That way additional channel information can be added.
>

why? we have another command (ETHTOOL_GNCSICINFO) to retrieve information
about the specified channel.

Cheers,
Gavin
