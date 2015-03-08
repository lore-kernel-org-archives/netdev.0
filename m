From: David R <david@unsolicited.net>
Subject: iptables problem upgrading kernel from 3.18.8 to 3.19.1
Date: Sun, 08 Mar 2015 10:12:25 +0000
Message-ID: <54FC2089.6080809@unsolicited.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I've just had an exception to my "uneventful kernel upgrade" monotony.

My boot scripts failed when setting up the firewall due to this :-

    xt_recent: hitcount (1) is larger than packets to be remembered (1)
for table xxxx

This is a completely straightforward

    iptables -A yyyy -j REJECT -p tcp --reject-with tcp-reset -m recent
--set --name xxxx --rsource

Looking at the history for xt_recent.c it looks like this was introduced
in abc86d0f99242b7f142b7cb8f90e30081dd3c256 but maybe corrected in
cef9ed86ed62eeffcd017882278bbece32001f86 ?

Whatever, 3.19.1 is still affected, it can be worked around by setting
ip_pkt_list_tot in the module parameters.

Cheers
David
