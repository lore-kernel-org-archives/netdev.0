From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] vlan: Fix the ingress VLAN_FLAG_REORDER_HDR check v2
Date: Fri, 3 Jun 2011 11:59:26 +0800
Message-ID: <BANLkTikM1TuO_S9LuJv30uV9oGgLjE09Xw@mail.gmail.com>
References: <m1aaectyed.fsf@fess.ebiederm.org> <20110524.022406.2228892895515155850.davem@davemloft.net>
 <m1oc2spmyt.fsf@fess.ebiederm.org> <20110601.205940.1179055860757569997.davem@davemloft.net>
 <m11uzcidvq.fsf_-_@fess.ebiederm.org> <BANLkTikjdz+LkavRiuqdDNS6+djAer-a0A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	David Miller <davem@davemloft.net>,
	shemminger@linux-foundation.org, greearb@candelatech.com,
	nicolas.2p.debian@gmail.com, jpirko@redhat.com,
	netdev@vger.kernel.org, kaber@trash.net, fubar@us.ibm.com,
	eric.dumazet@gmail.com, andy@greyhouse.net, jesse@nicira.com
To: padmanabh ratnakar <pratnakarlx@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:54155 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752735Ab1FCD7r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jun 2011 23:59:47 -0400
Received: by bwz15 with SMTP id 15so1464348bwz.19
        for <netdev@vger.kernel.org>; Thu, 02 Jun 2011 20:59:46 -0700 (PDT)
In-Reply-To: <BANLkTikjdz+LkavRiuqdDNS6+djAer-a0A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 3, 2011 at 11:34 AM, padmanabh ratnakar
<pratnakarlx@gmail.com> wrote:
> Doesnt __vlan_put_tag()/vlan_insert_tag() depend on skb->data pointing
> to ethernet header.
> Is'nt the skb->data pointing past ethernet header in netif_receive_skb().
> Am I missing anything?

Yes, you are right. skb->data should be adjusted before feeding to
vlan_insert_tag(), or we make vlan_insert_tag() rely on
skb->mac_header instead.

-- 
Regards,
Changli Gao(xiaosuo@gmail.com)
