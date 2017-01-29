From: marcelo.leitner@gmail.com
Subject: Re: [PATCHv3 net-next 3/4] sctp: add support for generating stream
 reconf add incoming/outgoing streams request chunk
Date: Sun, 29 Jan 2017 12:31:17 -0200
Message-ID: <20170129143117.GK3781@localhost.localdomain>
References: <063D6719AE5E284EB5DD2968C1650D6DB026900F@AcuExch.aculab.com>
 <20170120163921.GU3781@localhost.localdomain>
 <063D6719AE5E284EB5DD2968C1650D6DB026B8E0@AcuExch.aculab.com>
 <20170123.105810.222331205902181203.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David.Laight@ACULAB.COM, lucien.xin@gmail.com,
        netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        nhorman@tuxdriver.com, vyasevich@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42106 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750978AbdA2Obb (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 29 Jan 2017 09:31:31 -0500
Content-Disposition: inline
In-Reply-To: <20170123.105810.222331205902181203.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 23, 2017 at 10:58:10AM -0500, David Miller wrote:
> If this is "so critical" for end to end communication, why the heck
> do you not see __packed sprinkled all over our definitions for IPV4,
> IPV6, TCP, UDP, etc. headers?
> 
> Do you know why?  Because it's completely unnecessary...

Btw, virtually all sctp headers are currently tagged with __packed,
since forever.

$ git grep __packed -- include/linux/sctp.h
include/linux/sctp.h:} __packed sctp_sctphdr_t;
include/linux/sctp.h:} __packed sctp_chunkhdr_t;
include/linux/sctp.h:} __packed sctp_paramhdr_t;
include/linux/sctp.h:} __packed sctp_datahdr_t;
include/linux/sctp.h:} __packed sctp_data_chunk_t;
include/linux/sctp.h:} __packed sctp_inithdr_t;
include/linux/sctp.h:} __packed sctp_init_chunk_t;
include/linux/sctp.h:} __packed sctp_ipv4addr_param_t;
include/linux/sctp.h:} __packed sctp_ipv6addr_param_t;
include/linux/sctp.h:} __packed sctp_cookie_preserve_param_t;
include/linux/sctp.h:} __packed sctp_hostname_param_t;
include/linux/sctp.h:} __packed sctp_supported_addrs_param_t;
include/linux/sctp.h:} __packed sctp_ecn_capable_param_t;
include/linux/sctp.h:} __packed sctp_adaptation_ind_param_t;
include/linux/sctp.h:} __packed sctp_supported_ext_param_t;
include/linux/sctp.h:} __packed sctp_random_param_t;
include/linux/sctp.h:} __packed sctp_chunks_param_t;
include/linux/sctp.h:} __packed sctp_hmac_algo_param_t;
include/linux/sctp.h:} __packed sctp_cookie_param_t;
include/linux/sctp.h:} __packed sctp_unrecognized_param_t;
include/linux/sctp.h:} __packed sctp_gap_ack_block_t;
include/linux/sctp.h:} __packed sctp_sackhdr_t;
include/linux/sctp.h:} __packed sctp_sack_chunk_t;
include/linux/sctp.h:} __packed sctp_heartbeathdr_t;
include/linux/sctp.h:} __packed sctp_heartbeat_chunk_t;
include/linux/sctp.h:} __packed sctp_abort_chunk_t;
include/linux/sctp.h:} __packed sctp_shutdownhdr_t;
include/linux/sctp.h:} __packed;
include/linux/sctp.h:} __packed sctp_errhdr_t;
include/linux/sctp.h:} __packed sctp_operr_chunk_t;
include/linux/sctp.h:} __packed sctp_ecne_chunk_t;
include/linux/sctp.h:} __packed sctp_cwr_chunk_t;
...

^1da177e4c3f4 (Linus Torvalds           2005-04-16 15:20:36 -0700  64) }
__attribute__((packed)) sctp_sctphdr_t;

I'm reviewing them all and will probably post a patch to remove them.

  Marcelo
