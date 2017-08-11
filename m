From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next v2] vxlan: change vxlan_[config_]validate() to
 use netlink_ext_ack for error reporting
Date: Fri, 11 Aug 2017 19:11:55 +0200
Message-ID: <20170811191155.4906360a@griffin>
References: <1502399795-25660-1-git-send-email-girish.moodalbail@oracle.com>
        <CAJieiUjYggf3zNzwBMFq7zUm+RrZokZ7oNpuz-Hinec=0OSGzA@mail.gmail.com>
        <20170811183957.47f418e6@griffin>
        <62ddb5a5-2242-abea-7702-fbf7377d8a1e@gmail.com>
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
Received: from mx1.redhat.com ([209.132.183.28]:49694 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752723AbdHKRL7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 11 Aug 2017 13:11:59 -0400
In-Reply-To: <62ddb5a5-2242-abea-7702-fbf7377d8a1e@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 11 Aug 2017 10:56:57 -0600, David Ahern wrote:
> I would argue none of those messages are sufficient. The message should
> tell the user what is missing.

Good point.

I guess "The IFLA_INFO_DATA attribute is missing" would be a better
message. It can happen only when you're implementing your own
management tool, it's not that you'll get this message out of the ip
tool, thus referring to netlink attributes should be okay.

> What is the point of the !data check anyway? Based on the rest of the
> validate function neither IFLA_VXLAN_ID or IFLA_VXLAN_PORT_RANGE are
> required attributes.

The newlink callback assumes data is not NULL, i.e. IFLA_INFO_DATA is
present. It would crash otherwise.

 Jiri
