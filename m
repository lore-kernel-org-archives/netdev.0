From: Elad Lahav <elahav@uwaterloo.ca>
Subject: Re: [PATCH] Implementation of the sendgroup() system call
Date: Mon, 04 May 2009 20:24:35 -0400
Message-ID: <49FF8743.1090704@uwaterloo.ca>
References: <49FE47A1.7070700@uwaterloo.ca> <87eiv5ibnd.fsf@basil.nowhere.org> <20090504094431.174745mb0jhhm3s4@www.nexusmail.uwaterloo.ca> <20090504145046.GI23223@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Elad Lahav <elahav@cs.uwaterloo.ca>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758254AbZEEAX6@vger.kernel.org>
In-Reply-To: <20090504145046.GI23223@one.firstfloor.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> How much is non negligible in your case?
Please see the following link

http://www.cs.uwaterloo.ca/~elahav/sendgroup/mb_pkt_size.pdf

for a graph showing the (amortised) cost of sending a single packet to a 
group of 1000 recipients, using one of the three following methods:

1. A user-mode loop of sendmsg() calls
2. A kernel-mode loop of udp_sendmsg() calls
3. A single call to sendgroup()
The cost is measured in cycles and was determined using performance 
counters.

In this benchmark, savings introduced by sendgroup() are primarily due 
to the aviodence of multiple system calls, up to a packet size of about 
1000 bytes. Obviously, proportions change for different group sizes 
(though we were able to outperform method 1 with a group size as small 
as 2).

--Elad
