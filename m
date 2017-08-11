From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH net-next v2] vxlan: change vxlan_[config_]validate() to
 use netlink_ext_ack for error reporting
Date: Fri, 11 Aug 2017 11:17:54 -0600
Message-ID: <0af5e8f9-36cf-8aed-b431-ffc19eac4c8f@gmail.com>
References: <1502399795-25660-1-git-send-email-girish.moodalbail@oracle.com>
 <CAJieiUjYggf3zNzwBMFq7zUm+RrZokZ7oNpuz-Hinec=0OSGzA@mail.gmail.com>
 <20170811183957.47f418e6@griffin>
 <62ddb5a5-2242-abea-7702-fbf7377d8a1e@gmail.com>
 <20170811191155.4906360a@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Roopa Prabhu <roopa@cumulusnetworks.com>,
        Girish Moodalbail <girish.moodalbail@oracle.com>,
        pravin shelar <pshelar@ovn.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Matthias Schiffer <mschiffer@universe-factory.net>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33006 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753321AbdHKRR4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Aug 2017 13:17:56 -0400
Received: by mail-pf0-f195.google.com with SMTP id c65so3981234pfl.0
        for <netdev@vger.kernel.org>; Fri, 11 Aug 2017 10:17:56 -0700 (PDT)
In-Reply-To: <20170811191155.4906360a@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/11/17 11:11 AM, Jiri Benc wrote:
> On Fri, 11 Aug 2017 10:56:57 -0600, David Ahern wrote:
>> I would argue none of those messages are sufficient. The message should
>> tell the user what is missing.
> 
> Good point.
> 
> I guess "The IFLA_INFO_DATA attribute is missing" would be a better
> message. It can happen only when you're implementing your own
> management tool, it's not that you'll get this message out of the ip
> tool, thus referring to netlink attributes should be okay.
> 
>> What is the point of the !data check anyway? Based on the rest of the
>> validate function neither IFLA_VXLAN_ID or IFLA_VXLAN_PORT_RANGE are
>> required attributes.
> 
> The newlink callback assumes data is not NULL, i.e. IFLA_INFO_DATA is
> present. It would crash otherwise.


What if a user adds IFLA_INFO_DATA but adds no vxlan attributes under
it? Still not a valid config, but it passes the !data check.

Whatever attributes are required but missing should be the message
returned.
