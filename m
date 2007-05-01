From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: udp hash change and ipv6
Date: Tue, 01 May 2007 13:07:17 +0900 (JST)
Message-ID: <20070501.130717.115545945.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:36898 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946311AbXEAEHM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 May 2007 00:07:12 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave,

Because I do not have enough time before depature to Lima
via LAX, I cannot send a full fix for this, but anyway...

In net-2.6, __udp_lib_get_port() touches inet_sk(sk)->rcv_saddr,
which will break ipv6, I think.  We probably need to add a
extra function pointer to check is sk has wildcard rcv_saddr
for the protocol.

static udp4_is_rcvaddr_any(const struct sock *sk)
{
    return (!inet_sk(sk)->rcv_saddr);
}

static udp6_is_rcvaddr_any(const struct sock *sk)
{
    return (ipv6_addr_any(inet_sk(sk)->rcv_saddr));
}

Or something.  We may need to think about ipv6only socket
option.

Regards,

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
