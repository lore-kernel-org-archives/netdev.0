From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: Re: [PATCH v4 net-next 06/10] net/ncsi: Ethtool operation to get
 NCSI hw statistics
Date: Thu, 4 May 2017 10:55:58 +1000
Message-ID: <20170504005558.GB16780@gwshan>
References: <1493786681-27468-1-git-send-email-gwshan@linux.vnet.ibm.com>
 <1493786681-27468-7-git-send-email-gwshan@linux.vnet.ibm.com>
 <20170503124722.GE8029@lunn.ch>
 <20170503.091823.747316360571887178.davem@davemloft.net>
 <20170504000534.GA11287@gwshan>
 <20170504003452.GO8029@lunn.ch>
Reply-To: Gavin Shan <gwshan@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gavin Shan <gwshan@linux.vnet.ibm.com>,
        David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        joe@perches.com, kubakici@wp.pl, f.fainelli@gmail.com
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:56484 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752375AbdEDA5C (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 3 May 2017 20:57:02 -0400
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v440rjJg040329
        for <netdev@vger.kernel.org>; Wed, 3 May 2017 20:57:01 -0400
Received: from e23smtp07.au.ibm.com (e23smtp07.au.ibm.com [202.81.31.140])
        by mx0b-001b2d01.pphosted.com with ESMTP id 2a7cytks0c-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 03 May 2017 20:57:01 -0400
Received: from localhost
        by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
        Thu, 4 May 2017 10:56:58 +1000
Received: from d23av05.au.ibm.com (d23av05.au.ibm.com [9.190.234.119])
        by d23relay07.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v440ulgp4325674
        for <netdev@vger.kernel.org>; Thu, 4 May 2017 10:56:56 +1000
Received: from d23av05.au.ibm.com (localhost [127.0.0.1])
        by d23av05.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v440uNOf004733
        for <netdev@vger.kernel.org>; Thu, 4 May 2017 10:56:23 +1000
Content-Disposition: inline
In-Reply-To: <20170504003452.GO8029@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 04, 2017 at 02:34:52AM +0200, Andrew Lunn wrote:
>On Thu, May 04, 2017 at 10:05:34AM +1000, Gavin Shan wrote:
>> On Wed, May 03, 2017 at 09:18:23AM -0400, David Miller wrote:
>> >From: Andrew Lunn <andrew@lunn.ch>
>> >Date: Wed, 3 May 2017 14:47:22 +0200
>> >
>> >> On Wed, May 03, 2017 at 02:44:37PM +1000, Gavin Shan wrote:
>> >>> This adds ethtool command (ETHTOOL_GNCSISTATS) to retrieve the
>> >>> NCSI hardware statistics.
>> >> 
>> >> Hi Gavin
>> >> 
>> >> I've not been following this patchset, so maybe i'm about to ask a
>> >> question which has already been asked and answered.
>> >> 
>> >> Why cannot use just use ethtool -S for this?
>> >
>> >Indeed, when I said to use ethtool for these NCSI hw stats I meant
>> >that the "ethtool -S" be used, not some new ethtool command.
>> >
>> 
>> Thanks for the comments. Feel free to ask any questions which would
>> make the code clear and better. There are couple of factors I thought
>> separate command is better than ETHTOOL_GSTATS: The statistic items from
>> ETHTOOL_GSTATS are variable, meaning the kernel needs provide the layout
>> of the statistic items via ETHTOOL_GSSET_INFO and ETHTOOL_GSTRINGS.
>> NCSI HW statistics aren't following this and their layout is fixed.
>
>That does not stop you from using it for a fixed layout. And what
>happens when a new version of the standard is released with more
>statistics?
>

Correct, I don't see the difference between NCSI spec 1.01 and 1.1.0.
So I assume it's pretty stable, but still have potential to change.

I agree to collect NCSI HW statistic with ETHTOOL_GSTATS as I said
in another thread.

>> Besides, statistics for ETHTOOL_GSTATS are maintained in local MAC,
>> but NCSI HW statistics are collected from NIC on far-end. So they're
>> different from this point. 
>
>You might want to take a look at what is happening with Ethernet
>switches. Again, we have two sets of statistics for each port on the
>switch. We have the statistics from the hardware, and statistics from
>the software. Frames that come in one interface and the hardware
>forwards out another interface are not seen by the software. But
>frames which originate/terminate in the host, or the switch does not
>know what to do with and so are passed to the host, are seen by the
>software. Mellanox can tell you more. Your local and remote are not
>that different.
>

Yeah, it makes sense. Thanks for making an example here.

>> Lastly, the NCSI software statistics needs separate command. It'd
>> better to have separate command for HW statistics as well, to make
>> things consistent.
>
>Are software statistics defined in DSP0222? Since they are software, i
>kind of expect you want the flexibility to add more later. The
>ETHTOOL_GSSET_INFO and ETHTOOL_GSTRINGS gives you that flexibility,
>without having to change ethtool.
>

No, they're purely software implementation, not defined in DSP0222.
These statistics count the NCSI packets seen by software, not hardware.
It's used for diagnosis.

It's a nice suggestion to convey SW statistic with ETHTOOL_GSTATS,
ETHTOOL_GSSET_INFO and ETHTOOL_GSTRINGS, for better flexibility. I'll
follow this in next respin.

Cheers,
Gavin
