From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH 1/1] vxlan: make the struct nlattr variable const
Date: Sun, 4 Sep 2016 14:27:53 +0200
Message-ID: <20160904142753.3b5bc6a1@griffin>
References: <1472911630-22285-1-git-send-email-zyjzyj2000@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pabeni@redhat.com, daniel@iogearbox.net,
        pshelar@nicira.com, aduyck@mirantis.com,
        hannes@stressinduktion.org, davem@davemloft.net
To: zyjzyj2000@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42952 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750729AbcIDM17 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 4 Sep 2016 08:27:59 -0400
In-Reply-To: <1472911630-22285-1-git-send-email-zyjzyj2000@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat,  3 Sep 2016 22:07:10 +0800, zyjzyj2000@gmail.com wrote:
> From: Zhu Yanjun <zyjzyj2000@gmail.com>
> 
> The struct nlattr variable should not be changed.

True. But the only caller is vxlan_fdb_parse which doesn't have its tb
parameter const, so what's the point?

Now, the tb parameter of vxlan_fdb_parse could be changed to const.
This again doesn't make much sense without modifying its callers, which
are vxlan_fdb_add and vxlan_fdb_delete. And those are net_device_ops
hooks. Have you considered looking into those (ndo_fdb_*) and turning
the struct nlattr ** to const (that is, if it's possible)?

 Jiri
