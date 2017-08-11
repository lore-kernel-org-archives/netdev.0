From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next v2] vxlan: change vxlan_[config_]validate() to
 use netlink_ext_ack for error reporting
Date: Fri, 11 Aug 2017 19:28:06 +0200
Message-ID: <20170811192806.4910368f@griffin>
References: <1502399795-25660-1-git-send-email-girish.moodalbail@oracle.com>
        <CAJieiUjYggf3zNzwBMFq7zUm+RrZokZ7oNpuz-Hinec=0OSGzA@mail.gmail.com>
        <20170811183957.47f418e6@griffin>
        <62ddb5a5-2242-abea-7702-fbf7377d8a1e@gmail.com>
        <20170811191155.4906360a@griffin>
        <0af5e8f9-36cf-8aed-b431-ffc19eac4c8f@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Roopa Prabhu <roopa@cumulusnetworks.com>,
        Girish Moodalbail <girish.moodalbail@oracle.com>,
        pravin shelar <pshelar@ovn.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Matthias Schiffer <mschiffer@universe-factory.net>
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54394 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752989AbdHKR2K (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 11 Aug 2017 13:28:10 -0400
In-Reply-To: <0af5e8f9-36cf-8aed-b431-ffc19eac4c8f@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 11 Aug 2017 11:17:54 -0600, David Ahern wrote:
> What if a user adds IFLA_INFO_DATA but adds no vxlan attributes under
> it? Still not a valid config, but it passes the !data check.

Part of the checking is done in the newlink callback (vxlan_nl2conf).
Not nice but that's how it is. It's out of scope of this patch to
change that. (It's also not easy - most of the newlink logic would have
to be repeated in validate.)

The !data check needs to be done prior to blindly dereferencing into
data. It's currently in the validate callback. A bit chaotic but it
works. This patch just adds error messages.

> Whatever attributes are required but missing should be the message
> returned.

See the message I proposed in the previous email. newlink will take
care of the rest.

Feel free to submit cleanups, the vxlan driver could use them.

 Jiri
