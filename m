From: Rick Jones <rick.jones2@hp.com>
Subject: Re: ping DOS avoidance?
Date: Thu, 15 Mar 2007 09:44:43 -0700
Message-ID: <45F977FB.1050407@hp.com>
References: <d9dc600703091718m508cdafbm46a4aad9b613d9c1@mail.gmail.com> <d9dc600703141859x3eeddd4cs51b3aea89d4dc32a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev List <netdev@vger.kernel.org>
To: Luis Carlos Cobo Rus <luiscarlos@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel11.hp.com ([156.153.255.246]:40564 "EHLO palrel11.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030580AbXCOQop (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Mar 2007 12:44:45 -0400
In-Reply-To: <d9dc600703141859x3eeddd4cs51b3aea89d4dc32a@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I was just asked about something not too different, involving IIRC 
tnsping.  It got me to looking at ip_sysctl.txt which has:

icmp_ratelimit - INTEGER
         Limit the maximal rates for sending ICMP packets whose type
         matches icmp_ratemask (see below) to specific targets.
         0 to disable any limiting, otherwise the maximal rate in
         jiffies(1)
         Default: 100

icmp_ratemask - INTEGER
         Mask made of ICMP types for which rates are being limited.
         Significant bits: IHGFEDCBA9876543210
         Default mask:     0000001100000011000 (6168)

         Bit definitions (see include/linux/icmp.h):
                 0 Echo Reply
                 3 Destination Unreachable *
                 4 Source Quench *
                 5 Redirect
                 8 Echo Request
                 B Time Exceeded *
                 C Parameter Problem *
                 D Timestamp Request
                 E Timestamp Reply
                 F Info Request
                 G Info Reply
                 H Address Mask Request
                 I Address Mask Reply

         * These are rate limited by default (see default mask above)


(I've always been used to masks being specified as hex values)

rick jones
