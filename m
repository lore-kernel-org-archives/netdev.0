From: Changli Gao <xiaosuo@gmail.com>
Subject: [RFC] act_cpu: redirect skb receiving to a special CPU.
Date: Sat, 5 Jun 2010 18:56:13 +0800
Message-ID: <AANLkTikskTWJrULj2IKYhebxh9O_XTOMBy3i0wPY8thq@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Jamal Hadi Salim <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:33764 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932773Ab0FEK4g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jun 2010 06:56:36 -0400
Received: by pvg16 with SMTP id 16so895073pvg.19
        for <netdev@vger.kernel.org>; Sat, 05 Jun 2010 03:56:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am going to implement a CPU action, which can be used with ingress
qdisc to redirect skb receiving to a special cpu. It is much like RPS,
but more flexible:

* choose the hash function with the help of cls_flow.c
* pin special traffic to a dedicate CPU
* weighted packets distributing

act_cpu will use the function enqueue_to_backlog() supplied by RPS to
redirect skb receiving, and have two kind paramter:

* cpu CPUID - the ID of CPU, which handles this traffic
* map OFFSET - map the mirror class ID to CPUID: CPUID = mirror class ID + CPUID

sch_ingress will be enhanced to support class tree.

-- 
Regards,
Changli Gao(xiaosuo@gmail.com)
