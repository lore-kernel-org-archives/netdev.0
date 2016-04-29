From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH v3 net-next 6/7] net: do not block BH while processing
 socket backlog
Date: Fri, 29 Apr 2016 14:47:10 -0700
Message-ID: <5723D65E.1040806@fb.com>
References: <1461964613-4872-1-git-send-email-edumazet@google.com>
 <1461964613-4872-7-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Soheil Hassas Yeganeh <soheil@google.com>,
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Eric Dumazet <edumazet@google.com>,
	"David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:14871 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751907AbcD2VrR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2016 17:47:17 -0400
In-Reply-To: <1461964613-4872-7-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/29/16 2:16 PM, Eric Dumazet wrote:
> Socket backlog processing is a major latency source.
>
> With current TCP socket sk_rcvbuf limits, I have sampled __release_sock()
> holding cpu for more than 5 ms, and packets being dropped by the NIC
> once ring buffer is filled.
>
> All users are now ready to be called from process context,
> we can unblock BH and let interrupts be serviced faster.
>
> cond_resched_softirq() could be removed, as it has no more user.
>
> Signed-off-by: Eric Dumazet<edumazet@google.com>
> Acked-by: Soheil Hassas Yeganeh<soheil@google.com>

Acked-by: Alexei Starovoitov <ast@kernel.org>
