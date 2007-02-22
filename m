From: "Hua Zhong" <hzhong@gmail.com>
Subject: Linux 2.6 HTB does only work with existing connections
Date: Wed, 21 Feb 2007 17:44:31 -0800
Message-ID: <01de01c75623$00179ca0$0046d5e0$@com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.236]:44691 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1945942AbXBVBom (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Feb 2007 20:44:42 -0500
Received: by nz-out-0506.google.com with SMTP id s1so21820nze
        for <netdev@vger.kernel.org>; Wed, 21 Feb 2007 17:44:41 -0800 (PST)
Content-Language: en-us
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

I tried to use HTB on a 2.6.12 based kernel. It seems that if I issue the tc
commands, existing connections adjust bandwidth immediately, but any new
connections won't be filtered correctly.

The tc version is 3.17.

The commands are very simple (only eth1 is active):

    tc qdisc del dev eth1 root
    tc qdisc add dev eth1 root handle 1: htb default 20
    tc class add dev eth1 parent 1: classid 1:20 htb rate 4000kbit

No filters, just limit everything to under 4Mbit.

Then run ttcp to a remote machine, ifconfig shows eth1 is not limited.

However, while ttcp is running, issue the above three commands again, the
bandwidth is then limited correctly.

Any ideas?

The following are the show commands:

# tc qdisc show dev eth1
qdisc htb 1: r2q 10 default 20 direct_packets_stat 11
# tc class show dev eth1
class htb 1:20 root prio 0 rate 4000Kbit ceil 4000Kbit burst 2099b cburst
2099b

Please cc me.

Hua

