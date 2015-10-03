From: Ben Greear <greearb@candelatech.com>
Subject: Re: Slow ramp-up for single-stream TCP throughput on 4.2 kernel.
Date: Sat, 03 Oct 2015 15:46:42 -0700
Message-ID: <56105AD2.7070906@candelatech.com>
References: <560F1672.5000602@candelatech.com>	<560F1F74.9010207@candelatech.com> <CADVnQym4U_dVVRdOVhORvVabwFjSHTQJ_LbbbYtzWVu0=mAp_A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	ath10k <ath10k@lists.infradead.org>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.candelatech.com ([208.74.158.173]:49937 "EHLO
	mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750745AbbJCWqo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Oct 2015 18:46:44 -0400
In-Reply-To: <CADVnQym4U_dVVRdOVhORvVabwFjSHTQJ_LbbbYtzWVu0=mAp_A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 10/03/2015 09:29 AM, Neal Cardwell wrote:
> On Fri, Oct 2, 2015 at 8:21 PM, Ben Greear <greearb@candelatech.com> wrote:
>> Gah, seems 'cubic' related.  That is the default tcp cong ctrl
>> I was using (same in 3.17, for that matter).
>
> There have been recent changes to CUBIC that may account for this. If
> you could repeat your test with more instrumentation, eg "nstat", that
> would be very helpful.
>
> nstat > /dev/null
> # run one test
> nstat
>
> Also, if you could take a sender-side tcpdump trace of the test, that
> would be very useful (default capture length, grabbing just headers,
> is fine).

Here is nstat output:

[root@ben-ota-1 ~]# nstat
#kernel
IpInReceives                    14507              0.0
IpInDelivers                    14507              0.0
IpOutRequests                   49531              0.0
TcpActiveOpens                  3                  0.0
TcpPassiveOpens                 2                  0.0
TcpInSegs                       14498              0.0
TcpOutSegs                      50269              0.0
UdpInDatagrams                  9                  0.0
UdpOutDatagrams                 1                  0.0
TcpExtDelayedACKs               43                 0.0
TcpExtDelayedACKLost            5                  0.0
TcpExtTCPHPHits                 483                0.0
TcpExtTCPPureAcks               918                0.0
TcpExtTCPHPAcks                 12758              0.0
TcpExtTCPDSACKOldSent           5                  0.0
TcpExtTCPRcvCoalesce            49                 0.0
TcpExtTCPAutoCorking            3                  0.0
TcpExtTCPOrigDataSent           49776              0.0
TcpExtTCPHystartTrainDetect     1                  0.0
TcpExtTCPHystartTrainCwnd       16                 0.0
IpExtInBcastPkts                8                  0.0
IpExtInOctets                   2934274            0.0
IpExtOutOctets                  74817312           0.0
IpExtInBcastOctets              640                0.0
IpExtInNoECTPkts                14911              0.0
[root@ben-ota-1 ~]#


And, you can find the pcap here:

http://www.candelatech.com/downloads/cubic.pcap.bz2

Let me know if you need anything else.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
