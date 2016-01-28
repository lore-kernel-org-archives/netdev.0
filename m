From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH V2] netfilter: h323: avoid potential attack
Date: Thu, 28 Jan 2016 04:57:01 -0800
Message-ID: <1453985821.7627.17.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1453971597-4811-1-git-send-email-zhouzhouyi@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, kaber@trash.net, kadlec@blackhole.kfki.hu,
	davem@davemloft.net, netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.or, Zhouyi Zhou <yizhouzhou@ict.ac.cn>
To: Zhouyi Zhou <zhouzhouyi@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1453971597-4811-1-git-send-email-zhouzhouyi@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2016-01-28 at 16:59 +0800, Zhouyi Zhou wrote:
> Thanks Eric for your review and advice.
> 
> I think hackers chould build a malicious h323 packet to overflow
> the pointer p which will panic during the memcpy(addr, p, len)
> 
> For example, he may fabricate a very large taddr->ipAddress.ip;
> 
> Signed-off-by: Zhouyi Zhou <yizhouzhou@ict.ac.cn>
> ---

Except you did not address my feedback about potentially reading not
initialized memory.

if the frame length was 1000 bytes, then surely accessing memory at
offset 8000 will either read garbage, or read data from a prior frame
and leak secrets.



