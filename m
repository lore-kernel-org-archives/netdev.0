From: "Vladislav Zolotarov" <vladz@broadcom.com>
Subject: Receiving of priority tagged packets
Date: Sun, 23 May 2010 02:36:31 -0700
Message-ID: <8628FE4E7912BF47A96AE7DD7BAC0AADDDC6675BEC@SJEXCHCCR02.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3880 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754003Ab0EWJgm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 May 2010 05:36:42 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,
We were playing with FCoE in our labs and saw the strange behavior of Linux networking stack in regard to priority-tagged frames (the ones that have a zero VID in a VLAN tag). We saw that until we explicitly added a zero vlan interface (vconfig add ethX 0) the stack refused to accept such packets both in HW VLAN acceleration mode (skb is indicated using vlan_hwaccel_receive_skb()) and in a regular mode (skb is indicated with netif_receive_skb()).

However "IEEE Std 802.1Q, 2006 Edition DRAFT D0.1" in section 6.7 states the following: 

Each Bridge Port shall support the following parameters for use by these (EISS tagging and detagging) functions:
	c) an Acceptable Frame Types parameter with at least one of the following values:
		1) Admit Only VLAN-tagged frames;
		2) Admit Only Untagged and Priority-tagged frames;
		3) Admit All frames

So I guess this means that priority tagged frames should be accepted together with the untagged frames on the default interface ethX.

Could anyone explain, pls., what's the expected behavior of the Linux Networking Stack in regard to the priority-tagged frames and what's expected to be configured in order to start accepting them?

Thanks in advance,
vlad

