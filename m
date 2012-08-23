From: Alex Bergmann <alex@linlab.net>
Subject: Re: [PATCH 1/1] tcp: Wrong timeout for SYN segments
Date: Thu, 23 Aug 2012 14:37:27 +0200
Message-ID: <50362407.9070805@linlab.net>
References: <503419D3.1080700@linlab.net>  <CAFbMe2M7ekc94bQk7vTS1LhScPd49VZ-zKOCUXhqwxXtL-nkuA@mail.gmail.com>  <50361AEA.6010807@linlab.net> <1345724123.5904.756.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "H.K. Jerry Chu" <hkjerry.chu@gmail.com>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1345724123.5904.756.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/23/2012 02:15 PM, Eric Dumazet wrote:
> On Thu, 2012-08-23 at 13:58 +0200, Alex Bergmann wrote:
>> On 08/22/2012 06:41 PM, H.K. Jerry Chu wrote:
> 
>>> This issue occurred to me right after I submitted the patch for RFC6298.
>>> I did not commit any more change because RFC compliance aside, 180secs
>>> just seem like eternity in the Internet age.
>>>
>>> (See my past post on this at
>>> http://marc.info/?l=linux-netdev&m=130759078118866&w=2)
>>
>> Okay, I missed that post during my search about the current situation.
> 
> I would suggest to increase TCP_SYN_RETRIES from 5 to 6.
> 
> 180 secs is eternity, but 31 secs is too small.
> 
> Can you repost a v2, only changing TCP_SYN_RETRIES ?

I hope the description is good enough.

Alex


>From be551f82499112e4775b6d579d58967510b6d492 Mon Sep 17 00:00:00 2001
From: Alexander Bergmann <alex@linlab.net>
Date: Thu, 23 Aug 2012 14:33:35 +0200
Subject: [PATCH 1/1] tcp: Increase timeout for SYN segments

Commit 9ad7c049 changed the initRTO from 3secs to 1sec in accordance to
RFC6298 (former RFC2988bis). This reduced the time till the last SYN
retransmission packet gets sent from 93secs to 31secs.

RFC1122 is stating that the retransmission should be done for at least 3
minutes, but this seems to be quite high.[1]

This patch increases the value of TCP_SYN_RETRIES to the value of 6,
providing a retransmission window of 63secs.

[1] RFC 1122 - 4.2.3.5 TCP Connection Failures

Signed-off-by: Alexander Bergmann <alex@linlab.net>
---
 include/net/tcp.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 1f000ff..f309e93 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -98,7 +98,7 @@ extern void tcp_time_wait(struct sock *sk, int state, int timeo);
                                 * 15 is ~13-30min depending on RTO.
                                 */
 
-#define TCP_SYN_RETRIES         5      /* number of times to retry active opening a
+#define TCP_SYN_RETRIES         6      /* number of times to retry active opening a
                                 * connection: ~180sec is RFC minimum   */
 
 #define TCP_SYNACK_RETRIES 5   /* number of times to retry passive opening a
-- 
1.7.8.6
