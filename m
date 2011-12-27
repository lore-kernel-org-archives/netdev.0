From: zrpeng <zrpeng@linx-info.com>
Subject: Why network stack not reply RST
Date: Tue, 27 Dec 2011 16:31:36 +0800
Message-ID: <201112271631.36154.zrpeng@linx-info.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [159.226.21.127] ([159.226.21.127]:32986 "EHLO
	mail.linx-info.com" rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1752021Ab1L0Iid (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Dec 2011 03:38:33 -0500
Received: from [172.17.0.100] (unknown [192.168.46.3])
	by mail.linx-info.com (Postfix) with ESMTP id 7335695C1C3
	for <netdev@vger.kernel.org>; Tue, 27 Dec 2011 16:28:56 +0800 (CST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi:
    Why network stack not reply RST?
    I am doing test recently based on kernel 2.6.32. In my case:
    1) The server application closed the established socket, the network stack 
sent FIN to client. The socket status in kernel's network stack was 
TCP_FIN_WAIT1.
    2) The client sent out a tcp packet with ACK bit set for the server's FIN, 
the packet also took new data.
    3) When the server received the packet, network stack entered "step 5" in 
function "tcp_rcv_state_process".
    4) Then came to 'case TCP_FIN_WAIT1:'
    5) Then came to judgement
if (tp->linger2 < 0 ||
					    (TCP_SKB_CB(skb)->end_seq != TCP_SKB_CB(skb)->seq &&
					     after(TCP_SKB_CB(skb)->end_seq - th->fin, tp->rcv_nxt))) {
.....
}
    6) Because the previous packet took data and ACK (for the FIN), it entered 
the judgement. So, the socket is deleted in function 'tcp_done(sk)'.
    7) No TCP message was sent back to client side from then on, and client 
was left in LAST_ACK status.

    My questions are:
    1) Is this process correct? I think the server should sent RST to client, 
is this correct?
    2) What's the using of judgement 
 (TCP_SKB_CB(skb)->end_seq != TCP_SKB_CB(skb)->seq &&
					     after(TCP_SKB_CB(skb)->end_seq - th->fin, tp->rcv_nxt)

       The code exists from kernel 2.3.41 and 2.3.42. 

    Thank you very much!
    Best Regards.

    Peng Zhaoran from Linx-Info Tech.
    
    www.linx-info.com
