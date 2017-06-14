From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [patch iproute2 v2 repost 2/3] tc: actions: add helpers to
 parse and print control actions
Date: Wed, 14 Jun 2017 20:32:22 +0200
Message-ID: <20170614203222.3dcc183d@griffin>
References: <20170516172802.1317-1-jiri@resnulli.us>
        <20170516172937.1391-2-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, jhs@mojatatu.com,
        xiyou.wangcong@gmail.com, dsa@cumulusnetworks.com,
        edumazet@google.com, stephen@networkplumber.org,
        daniel@iogearbox.net, alexander.h.duyck@intel.com,
        simon.horman@netronome.com, mlxsw@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50348 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750728AbdFNSc2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 14 Jun 2017 14:32:28 -0400
In-Reply-To: <20170516172937.1391-2-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 16 May 2017 19:29:36 +0200, Jiri Pirko wrote:
> From: Jiri Pirko <jiri@mellanox.com>
> 
> Each tc action is terminated by a control action. Each action parses and
> prints then intividually. Introduce set of helpers and allow to share
> this code.

This patch, as indicated by git bisect, broke tc if there are multiple
actions specified. This somehow non-real life reproducer (the real case
where this broke for me was more complex) works fine with 732f03461bc4:

# tc filter add dev eth0 parent 1: matchall action vlan push id 1 action drop

while with both the current net-next and with e67aba559581, the result
is:

# tc filter add dev eth0 parent 1: matchall action vlan push id 1 action drop
Bad action type action

 Jiri
