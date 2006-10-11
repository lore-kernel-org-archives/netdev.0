From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [PATCH-update][RFC] net: consolidated UDP / UDP-Lite code
Date: Wed, 11 Oct 2006 08:40:24 +0100
Message-ID: <200610110840.24515@strip-the-willow>
References: <20060727.223010.63131639.davem@davemloft.net> <200610091051.45021@strip-the-willow> <20061010.193828.10132678.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:47744 "EHLO erg.abdn.ac.uk")
	by vger.kernel.org with ESMTP id S1030676AbWJKHkm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2006 03:40:42 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20061010.193828.10132678.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

|  >  csum_copy_err:
|  > -	UDP_INC_STATS_BH(UDP_MIB_INERRORS);
|  > +	UDP_INC_STATS_BH(UDP_MIB_INERRORS, is_udplite);
|  > +	UDP_DEC_STATS_BH(UDP_MIB_INDATAGRAMS, is_udplite);
|  
|  I'm not a big fan at all of these "statistic corrections"
|  we're starting to place in various spots.
I am not really fond of this solution either. It evolved via discussion, from a
previous suggestion to place the increment of InDatagrams into udp_recvmsg(). 
The problem with that alternative was in dealing with applications which use the
data_ready handler (such as sunrpc).

|  I really don't think it's the end of the world if we count as
|  INDATAGRAMS a packet that we later discover has a bad checksum.
It would have been nice to say "all these counters count correctly". Maybe that 
has been over-ambitious - in  tcp_ipv4.c I found that tcp_v4_rcv also counts 
incoming segments even if they are bad.

I will restore the original state and remove the counter decrements in the
next upcoming version of the patch.


Thank you,

-- Gerrit
