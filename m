From: PanBian <bianpan2016@163.com>
Subject: Re: [PATCH 1/1] tipc: check return value of nlmsg_new
Date: Sun, 23 Apr 2017 16:00:27 +0800
Message-ID: <20170423080027.GA843@bp>
References: <1492931359-25004-1-git-send-email-bianpan2016@163.com>
 <1492931836.30293.43.camel@perches.com>
Reply-To: PanBian <bianpan2016@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ying Xue <ying.xue@windriver.com>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        tipc-discussion@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from m50-135.163.com ([123.125.50.135]:47221 "EHLO m50-135.163.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1427852AbdDWIBN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 23 Apr 2017 04:01:13 -0400
Content-Disposition: inline
In-Reply-To: <1492931836.30293.43.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 23, 2017 at 12:17:16AM -0700, Joe Perches wrote:
> On Sun, 2017-04-23 at 15:09 +0800, Pan Bian wrote:
> > Function nlmsg_new() will return a NULL pointer if there is no enough
> > memory, and its return value should be checked before it is used.
> > However, in function tipc_nl_node_get_monitor(), the validation of the
> > return value of function nlmsg_new() is missed. This patch fixes the
> > bug.
> 
> Hello.
> 
> Thanks for the patches.
> 
> Are you finding these via a tool or inspection?
> 
> If a tool is being used, could you please describe it?
> 

Yes. I developed a tool to find this kind of bugs.

The detecting idea is simple. In large systems like the Linux kernel, 
most implementations are correct, and incorrect ones are rare. Based on
this observation, we take programs that have different implementations
with others as bugs. For example, in most cases, the return vlaue of
nlmsg_new() is validated and it will not be passed to genlmsg_reply() if
its value is NULL. However, in function tipc_nl_node_get_monitor(), the
validation is missing. The abnormal behavior leads us to believe that
there is a bug.


Thanks for your attention.
