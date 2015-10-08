From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net v2] fix return of iptunnel_xmit
Date: Thu, 8 Oct 2015 17:08:49 +0200
Message-ID: <20151008170849.22bc8632@griffin>
References: <1444299114-21345-1-git-send-email-aschultz@tpip.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Pravin B Shelar <pshelar@nicira.com>,
	"David S. Miller" <davem@davemloft.net>
To: Andreas Schultz <aschultz@tpip.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43379 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933554AbbJHPIx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Oct 2015 11:08:53 -0400
In-Reply-To: <1444299114-21345-1-git-send-email-aschultz@tpip.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu,  8 Oct 2015 12:11:54 +0200, Andreas Schultz wrote:
> All users of iptunnel_xmit expect the return value to be the error
> code from ip_output_local, but currently the return value is length
> of the send data on success or zero on error.
> Change iptunnel_xmit returns to match the callers expectation.

That's not true. All users pass the returned value to
iptunnel_xmit_stats() where it is used to increase tx_bytes.

The only exception is tipc_udp_send_msg which should be fixed instead.

 Jiri

-- 
Jiri Benc
