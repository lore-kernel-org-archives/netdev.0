From: Michael Faber <faber@i4.informatik.rwth-aachen.de>
Subject: tcp_info struct
Date: Mon, 26 Feb 2007 18:33:50 +0100
Message-ID: <45E319FE.8090707@i4.informatik.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from i4mail.informatik.RWTH-Aachen.DE ([137.226.12.21]:50265 "EHLO
	i4mail.informatik.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1030376AbXBZR6a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Feb 2007 12:58:30 -0500
Received: from i4mail (i4mail.informatik.rwth-aachen.de [137.226.12.21])
	by i4mail.informatik.rwth-aachen.de (Postfix) with ESMTP id 86228188F3
	for <netdev@vger.kernel.org>; Mon, 26 Feb 2007 18:33:50 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

i want to use the tcp_info struct to keep track of some tcp related
information. This works fine so far, however i'm wondering how to
interpret some of the values delivered. I would expect values like cwnd
and sst to be given out in packets regarding the source code. Can anyone
give me some hints in interpreting the tcp_info values as this option is
very poor documented and only documentation on how to fill the tcp_info
struct can be found.

Below are some values i got out of the tcp_info structure with the tcp
connection in state 8 and the code snippet which uses the tcp_struct.
Especially the SND_MSS (i would expect this to be 1460) and the ssthresh
value are strange.

tcp_info:
RTOs = 0, 0WProbes = 0, Backoffs = 0
RTO = 204 msec, RTT = 7 msec, RTT_var = 3 msec
lost packets = 0, sacked packets = 0, retransmitted packets = 1
SND_MSS = 16384, RCV_MSS = 536, ssthresh = 65535, cwnd = 13



struct tcp_info info;

int optlen=sizeof(struct tcp_info);

if(getsockopt(socket_fd, IPPROTO_TCP, TCP_INFO, &info, &optlen) < 0){
       // Error Handling
}
printf("RTOs = %u, 0WProbes = %u, Backoffs = %u\n\
            RTO = %u msec, RTT = %u msec, RTT_var = %u msec\n\
            lost packets = %u, sacked packets = %u, retransmitted
packets = %u\n\
            SND_MSS = %u, RCV_MSS = %u, ssthresh = %u, cwnd = %u \n\n",
            info.tcpi_retransmits, info.tcpi_probes, info.tcpi_backoff,
            (info.tcpi_rto/1000), (info.tcpi_rtt/1000),
(info.tcpi_rttvar/1000),
             info.tcpi_lost, info.tcpi_sacked, info.tcpi_total_retrans,
            info.tcpi_snd_mss, info.tcpi_rcv_mss,
info.tcpi_snd_ssthresh, info.tcpi_snd_cwnd);

thx
Michael


