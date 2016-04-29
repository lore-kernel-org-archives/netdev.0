From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH v2 net-next 7/7] tcp: make tcp_sendmsg() aware of socket
 backlog
Date: Thu, 28 Apr 2016 22:19:22 -0700
Message-ID: <5722EEDA.6060604@fb.com>
References: <1461899449-8096-1-git-send-email-edumazet@google.com>
 <1461899449-8096-8-git-send-email-edumazet@google.com>
 <5722E663.8080304@fb.com>
 <1461906355.5535.141.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	"David S . Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Soheil Hassas Yeganeh <soheil@google.com>,
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:61711 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751085AbcD2FT3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2016 01:19:29 -0400
In-Reply-To: <1461906355.5535.141.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/28/16 10:05 PM, Eric Dumazet wrote:
> On Thu, 2016-04-28 at 21:43 -0700, Alexei Starovoitov wrote:
>
>>
>> I don't understand the logic completely, but isn't it
>> safer to do 'goto wait_for_memory;' here if we happened
>> to hit this in the middle of the loop?
>
> Well, the wait_for_memory pushes data, and could early return to user
> space with short writes (non blocking IO). This would break things...

I see. Right. My only concern was about restarting the loop
and msg_data_left(), since it's really hard to follow iov_iter logic.
