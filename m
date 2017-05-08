From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: Re: [PATCH v4 net-next 08/10] net/ncsi: Support NCSI packet
 generation
Date: Mon, 8 May 2017 16:27:25 +1000
Message-ID: <20170508062725.GA1930@gwshan>
References: <1493786681-27468-1-git-send-email-gwshan@linux.vnet.ibm.com>
 <1493786681-27468-9-git-send-email-gwshan@linux.vnet.ibm.com>
 <20170503125254.GF8029@lunn.ch>
 <20170504063156.GA7620@gwshan>
 <20170504120035.GQ8029@lunn.ch>
 <20170508002512.GA6012@gwshan>
 <20170508005632.GF27709@lunn.ch>
Reply-To: Gavin Shan <gwshan@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gavin Shan <gwshan@linux.vnet.ibm.com>, netdev@vger.kernel.org,
        joe@perches.com, kubakici@wp.pl, f.fainelli@gmail.com,
        davem@davemloft.net
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:58776 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1753223AbdEHHrs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 8 May 2017 03:47:48 -0400
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v487cghV049886
        for <netdev@vger.kernel.org>; Mon, 8 May 2017 03:47:47 -0400
Received: from e23smtp08.au.ibm.com (e23smtp08.au.ibm.com [202.81.31.141])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2aakxead5q-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 08 May 2017 03:47:43 -0400
Received: from localhost
        by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
        Mon, 8 May 2017 16:30:21 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
        by d23relay09.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v486SFBq34275400
        for <netdev@vger.kernel.org>; Mon, 8 May 2017 16:28:23 +1000
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
        by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v486Rnfl020999
        for <netdev@vger.kernel.org>; Mon, 8 May 2017 16:27:50 +1000
Content-Disposition: inline
In-Reply-To: <20170508005632.GF27709@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 08, 2017 at 02:56:32AM +0200, Andrew Lunn wrote:
>> I need to dig how libpcap receives packets. It's appreciated if you
>> can give some hints about that. However, I don't see the benefit to
>> receive packets by libpcap, could you claim?
>
>The base interface should already be doing it for you. Try it! Run
>tcpdump or wireshark and you should see the NCSI packets going
>out/coming in. Look for the ethertype. Neither tcpdump or wireshark
>appear to have dissectors for NCSI, but it should be simple to
>write. I've written them before, and it is easy.
>
>Doing it in userspace will give you a much nice environment to work
>in. Wireshark can link the response to the request, do a much more
>detailed decode than what you want to do in kernel space, and in
>general it is safer. Wrongly decoding and printing protocols in kernel
>space can lead to a remote kernel vulnerability. Getting it wrong in
>user space 'just' allows a remote hack of a user account.
>

Andrew, thanks a lot for the hints. Yeah, I think it's implemented based
on AF_PACKET + ETH_P_ALL. NCSI packets has been included.

The output from (libpcap and debugfs) will be different, but I assume it's
not a problem. libpcap usually outputs all Tx/Rx NCSI packets while debugfs
file outputs received NCSI response packets that correspond to the NCSI command
packets sent via the debugfs interface.

In next respin, I'll move the Rx path to libpcap while the Tx is left in
the debugfs interace.

Cheers,
Gavin
