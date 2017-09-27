From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH v2 net-next 0/2] net/sched: support tunnel options in
 cls_flower and act_tunnel_key
Date: Wed, 27 Sep 2017 17:46:37 +0200
Message-ID: <20170927174637.28654c72@griffin>
References: <1506500194-17637-1-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, Jiri Pirko <jiri@mellanox.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org,
        oss-drivers@netronome.com
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53034 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752190AbdI0Pqk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 27 Sep 2017 11:46:40 -0400
In-Reply-To: <1506500194-17637-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 27 Sep 2017 10:16:32 +0200, Simon Horman wrote:
> * Geneve
> 
>   In the case of Geneve options are TLVs[1]. My reading is that in collect
>   metadata mode the kernel does not appear to do anything other than pass
>   them around as a bytestring.
> 
>   [1] https://tools.ietf.org/html/draft-ietf-nvo3-geneve-05#section-3.5
[...]
> 
> Neither of the above appear to assume any structure for the data.

But that's not true. Geneve uses TLVs, you even mentioned that
yourself. Matching on a block of TLVs as a bytestring doesn't make
sense. The TLV fields may be in any order.

We need better matching here. Bytestring is useless for Geneve.

NACK for this direction of option matching. We'd need to introduce
matching on TLVs sooner or later anyway and this would be just a never
used compat cruft that we need to keep around forever.

 Jiri
