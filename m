From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [v3.18] Fixes for ip_vti and ip6_vti
Date: Tue, 25 Aug 2015 15:21:19 +0200
Message-ID: <55DC6BCF.1040206@6wind.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Alexander Duyck <alexander.h.duyck@redhat.com>,
	Steffen Klassert <steffen.klassert@secunet.com>
To: stable <stable@vger.kernel.org>, netdev <netdev@vger.kernel.org>,
	Sasha Levin <sasha.levin@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:36789 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755549AbbHYNVX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 09:21:23 -0400
Received: by wicja10 with SMTP id ja10so15039957wic.1
        for <netdev@vger.kernel.org>; Tue, 25 Aug 2015 06:21:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

since commit ca7c7b9059e3 ("skbuff: Do not scrub skb mark within the same name
space", backport of upstream commit 213dd74aee76), the following three upstream
commits need also to be backported in the 3.18 branch:
  - cd5279c194f8 ("ip_vti/ip6_vti: Do not touch skb->mark on xmit")
  - 049f8e2e28d9 ("xfrm: Override skb->mark with tunnel->parm.i_key in
    xfrm_input")
  - d55c670cbc54 ("ip_vti/ip6_vti: Preserve skb->mark after rcv_cb call")

When the packet is handled by the ip_vti interface, it is temporarily marked
with the ip_vti interface key. Once the process is completed, the packet is
received via the ip_vti interface and its original mark should be restored
(typically to 0).
Before the backported patch, ip_vti counted on skb_scrub_packet to reset the
mark, but skb_scrub_packet nomore does.
Since the packet is still marked, it will match the outbound SP and so be
encrypted again.


Regards,
Nicolas
