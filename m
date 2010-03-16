From: Michael Breuer <mbreuer@majjas.com>
Subject: [Regression] 2.6.34-rc1 sky2 mtu on second port defaults to 576
Date: Tue, 16 Mar 2010 11:03:09 -0400
Message-ID: <4B9F9DAD.7060308@majjas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7BIT
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Haven't bisected - problem seemed to have started around 2.6.34-rc1-0933 
(not seen before the rc1 tag).

On boot, eth1 ends up with MTU of 576 (eth0 is 1500). My f12 startup 
scripts are not setting MTU (never have).


Nothing of note in dmesg
No change to .config
No mtu change reported in log.

Basically, sky2 reports eth1 up... and within the same second begins 
reporting receive length errors. Most network functions via eth1 fail.

ifconfig eth1 reveals mtu of 576, setting mtu to 1500 restores network 
functionality.

Booting back to 2.6.33-06233 (git from March 8) the problem does not 
manifest.

I'll bisect if this isn't obvious to someone.
