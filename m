From: Ji <lijimlee@gmail.com>
Subject: Question about TLP patch
Date: Wed, 23 Apr 2014 16:09:19 -0700
Message-ID: <CAJdgut_YYR4nNM88kbn5hqtDsj27wa5OT=jR9AVcV0b=yYon8Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:51031 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751126AbaDWXJU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2014 19:09:20 -0400
Received: by mail-pd0-f180.google.com with SMTP id v10so1255208pde.11
        for <netdev@vger.kernel.org>; Wed, 23 Apr 2014 16:09:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When reading the patch of Tail Loss Probe:
https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=6ba8a3b19e764b6a65e4030ab0999be50c291e6c
, I noticed this change:

@@ -2321,7 +2322,7 @@ static bool tcp_time_to_recover(struct sock *sk, int flag)
* interval if appropriate.
*/
if (tp->do_early_retrans && !tp->retrans_out && tp->sacked_out &&
- (tp->packets_out == (tp->sacked_out + 1) && tp->packets_out < 4) &&
+ (tp->packets_out >= (tp->sacked_out + 1) && tp->packets_out < 4) &&
!tcp_may_send_now(sk))
return !tcp_pause_early_retransmit(sk, flag);

I think the original code is because of RFC5827 Early Retransmit for TCP, 3.2
"... When conditions (3.a) and (3.b) hold and a TCP connection does

   support SACK or SCTP is in use, Early Retransmit MUST be used only

   when "oseg - 1" segments have been SACKed...."

With that change, it seems that the condition is relaxed. I wonder
why it is so. Could you cast some lights on it?

Thanks,
Ji Li
