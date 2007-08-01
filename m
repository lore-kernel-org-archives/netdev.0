From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [Lksctp-developers] [PATCH] SCTP: drop SACK if ctsn is not less
 than the next tsn of assoc
Date: Tue, 31 Jul 2007 23:15:03 -0400
Message-ID: <46AFFAB7.8050503@hp.com>
References: <18087.57737.908842.337891@zeus.sw.starentnetworks.com>		<46AEBE2B.1060702@cn.fujitsu.com>		<20070731113709.GA28333@hmsreliant.homelinux.net>	<1185902894.8234.5.camel@localhost.localdomain> <46AFDC97.6080909@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: Sridhar Samudrala <sri@us.ibm.com>, netdev@vger.kernel.org,
	lksctp-developers@lists.sourceforge.net,
	Neil Horman <nhorman@tuxdriver.com>
To: Wei Yongjun <yjwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.hp.com ([192.151.27.10]:60872 "EHLO mailhub.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751596AbXHADPH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Jul 2007 23:15:07 -0400
In-Reply-To: <46AFDC97.6080909@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sorry, coming in late due to list issues...

Wei Yongjun wrote:
>> On Tue, 2007-07-31 at 07:37 -0400, Neil Horman wrote:
>>   
>>> On Tue, Jul 31, 2007 at 12:44:27PM +0800, Wei Yongjun wrote:
>>>     
>>>> If SCTP data sender received a SACK which contains Cumulative TSN Ack is 
>>>> not less than the Cumulative TSN Ack Point, and if this Cumulative TSN 
>>>> Ack is not used by the data sender, SCTP data sender still accept this 
>>>> SACK , and next SACK which send correctly to DATA sender be dropped, 
>>>> because it is less than the new Cumulative TSN Ack Point.
>>>> After received this SACK, data will be retrans again and again even if 
>>>> correct SACK is received.
>>>> So I think this SACK must be dropped to let data transmit  correctly.
>>>>
>>>> Following is the tcpdump of my test. And patch in this mail can avoid 
>>>> this problem.
>>>>
>>>> 02:19:38.233278 sctp (1) [INIT] [init tag: 1250461886] [rwnd: 54784] [OS: 10] [MIS: 65535] [init TSN: 217114040] 
>>>> 02:19:39.782160 sctp (1) [INIT ACK] [init tag: 1] [rwnd: 54784] [OS: 100] [MIS: 65535] [init TSN: 100] 
>>>> 02:19:39.798583 sctp (1) [COOKIE ECHO] 
>>>> 02:19:40.082125 sctp (1) [COOKIE ACK] 
>>>> 02:19:40.097859 sctp (1) [DATA] (B)(E) [TSN: 217114040] [SID: 0] [SSEQ 0] [PPID 0xf192090b] 
>>>> 02:19:40.100162 sctp (1) [DATA] (B)(E) [TSN: 217114041] [SID: 0] [SSEQ 1] [PPID 0x3e467007] 
>>>> 02:19:40.100779 sctp (1) [DATA] (B)(E) [TSN: 217114042] [SID: 0] [SSEQ 2] [PPID 0x11b12a0a] 
>>>> 02:19:40.101200 sctp (1) [DATA] (B)(E) [TSN: 217114043] [SID: 0] [SSEQ 3] [PPID 0x30e7d979] 
>>>> 02:19:40.561147 sctp (1) [SACK] [cum ack 217114040] [a_rwnd 54784] [#gap acks 0] [#dup tsns 0] 
>>>> 02:19:40.568498 sctp (1) [DATA] (B)(E) [TSN: 217114044] [SID: 0] [SSEQ 4] [PPID 0x251ff86f] 
>>>> 02:19:40.569308 sctp (1) [DATA] (B)(E) [TSN: 217114045] [SID: 0] [SSEQ 5] [PPID 0xe5d5da5d] 
>>>> 02:19:40.700584 sctp (1) [SACK] [cum ack 290855864] [a_rwnd 54784] [#gap acks 0] [#dup tsns 0] 
>>>> 02:19:40.701562 sctp (1) [DATA] (B)(E) [TSN: 217114046] [SID: 0] [SSEQ 6] [PPID 0x87d8b423] 
>>>> 02:19:40.701567 sctp (1) [DATA] (B)(E) [TSN: 217114047] [SID: 0] [SSEQ 7] [PPID 0xca47e645] 
>>>> 02:19:40.701569 sctp (1) [DATA] (B)(E) [TSN: 217114048] [SID: 0] [SSEQ 8] [PPID 0x6c0ea150] 
>>>> 02:19:40.701576 sctp (1) [DATA] (B)(E) [TSN: 217114049] [SID: 0] [SSEQ 9] [PPID 0x9cc1994f] 
>>>> 02:19:40.701585 sctp (1) [DATA] (B)(E) [TSN: 217114050] [SID: 0] [SSEQ 10] [PPID 0xb1df4129] 
>>>> 02:19:41.098201 sctp (1) [SACK] [cum ack 217114041] [a_rwnd 54784] [#gap acks 0] [#dup tsns 0] 
>>>> 02:19:41.283257 sctp (1) [SACK] [cum ack 217114042] [a_rwnd 54784] [#gap acks 0] [#dup tsns 0] 
>>>> 02:19:41.457217 sctp (1) [SACK] [cum ack 217114043] [a_rwnd 54784] [#gap acks 0] [#dup tsns 0] 
>>>> 02:19:41.691528 sctp (1) [SACK] [cum ack 217114044] [a_rwnd 54784] [#gap acks 0] [#dup tsns 0] 
>>>> 02:19:41.849636 sctp (1) [SACK] [cum ack 217114045] [a_rwnd 54784] [#gap acks 0] [#dup tsns 0] 
>>>> 02:19:41.975473 sctp (1) [DATA] (B)(E) [TSN: 217114046] [SID: 0] [SSEQ 6] [PPID 0x87d8b423] 
>>>> 02:19:42.021229 sctp (1) [SACK] [cum ack 217114046] [a_rwnd 54784] [#gap acks 0] [#dup tsns 0] 
>>>> 02:19:42.196495 sctp (1) [SACK] [cum ack 217114047] [a_rwnd 54784] [#gap acks 0] [#dup tsns 0] 
>>>> 02:19:42.424319 sctp (1) [SACK] [cum ack 217114048] [a_rwnd 54784] [#gap acks 0] [#dup tsns 0] 
>>>> 02:19:42.586924 sctp (1) [SACK] [cum ack 217114049] [a_rwnd 54784] [#gap acks 0] [#dup tsns 0] 
>>>> 02:19:42.744810 sctp (1) [SACK] [cum ack 217114050] [a_rwnd 54784] [#gap acks 0] [#dup tsns 0] 
>>>> 02:19:42.965536 sctp (1) [SACK] [cum ack 217114046] [a_rwnd 54784] [#gap acks 0] [#dup tsns 0] 
>>>> 02:19:43.106385 sctp (1) [DATA] (B)(E) [TSN: 217114046] [SID: 0] [SSEQ 6] [PPID 0x87d8b423] 
>>>> 02:19:43.218969 sctp (1) [SACK] [cum ack 217114046] [a_rwnd 54784] [#gap acks 0] [#dup tsns 0] 
>>>> 02:19:45.374101 sctp (1) [DATA] (B)(E) [TSN: 217114046] [SID: 0] [SSEQ 6] [PPID 0x87d8b423] 
>>>> 02:19:45.489258 sctp (1) [SACK] [cum ack 217114046] [a_rwnd 54784] [#gap acks 0] [#dup tsns 0] 
>>>> 02:19:49.830116 sctp (1) [DATA] (B)(E) [TSN: 217114046] [SID: 0] [SSEQ 6] [PPID 0x87d8b423] 
>>>> 02:19:49.984577 sctp (1) [SACK] [cum ack 217114046] [a_rwnd 54784] [#gap acks 0] [#dup tsns 0] 
>>>> 02:19:58.760300 sctp (1) [DATA] (B)(E) [TSN: 217114046] [SID: 0] [SSEQ 6] [PPID 0x87d8b423] 
>>>> 02:19:58.931690 sctp (1) [SACK] [cum ack 217114046] [a_rwnd 54784] [#gap acks 0] [#dup tsns 0] 
>>>>
>>>>
>>>> Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
>>>>
>>>> --- net/sctp/sm_statefuns.c.orig	2007-07-29 18:11:01.000000000 -0400
>>>> +++ net/sctp/sm_statefuns.c	2007-07-29 18:14:49.000000000 -0400
>>>> @@ -2880,6 +2880,15 @@ sctp_disposition_t sctp_sf_eat_sack_6_2(
>>>>  		return SCTP_DISPOSITION_DISCARD;
>>>>  	}
>>>>  
>>>> +	/* If Cumulative TSN Ack is not less than the Cumulative TSN
>>>> +	 * Ack which will be send in the next data, drop the SACK.
>>>> +	 */
>>>> +	if (!TSN_lt(ctsn, asoc->next_tsn)) {
>>>> +		SCTP_DEBUG_PRINTK("ctsn %x\n", ctsn);
>>>> +		SCTP_DEBUG_PRINTK("next_tsn %x\n", asoc->next_tsn);
>>>> +		return SCTP_DISPOSITION_DISCARD;
>>>> +	}
>>>> +
>>>>  	/* Return this SACK for further processing.  */
>>>>  	sctp_add_cmd_sf(commands, SCTP_CMD_PROCESS_SACK, SCTP_SACKH(sackh));
>>>>  

This is an interesting case, but I am not sure that simply discarding
the SACK is the right thing.

The peer in this case is violating the protocol whereby he is trying to
advance the cumulative tsn ack to a point beyond the max tsn currently
sent.  I would vote for terminating the association in this case since
either the peer is a mis-behaved implementation, or the association is
under attack.

-vlad
