From: jamal <hadi@cyberus.ca>
Subject: Re: xfrm by MARK: tcp problems when mark for in and out differ
Date: Thu, 14 Oct 2010 08:02:21 -0400
Message-ID: <1287057741.3756.6.camel@bigi>
References: <201010131557.06588.lists@egidy.de>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dev@lists.strongswan.org
To: "Gerd v. Egidy" <lists@egidy.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:53923 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753881Ab0JNMCZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Oct 2010 08:02:25 -0400
Received: by gyd12 with SMTP id 12so24762gyd.19
        for <netdev@vger.kernel.org>; Thu, 14 Oct 2010 05:02:24 -0700 (PDT)
In-Reply-To: <201010131557.06588.lists@egidy.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-10-13 at 15:57 +0200, Gerd v. Egidy wrote:
> Hi,

> 
> -> incoming packets are without mark, outgoing packets are marked with 5
> 

You could use tc ingress path to mark incoming packets. Example:

----
tc qdisc add dev eth0 ingress
tc filter add dev eth0 parent ffff: protocol ip pref 9 u32 \
match ip src 192.168.1.0/32 flowid 1:5 action skbedit mark 5
---

just remember that src on outgoing is dst on incoming..


cheers,
jamal

