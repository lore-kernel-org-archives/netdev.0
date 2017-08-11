From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH net-next v2] vxlan: change vxlan_[config_]validate() to
 use netlink_ext_ack for error reporting
Date: Fri, 11 Aug 2017 10:56:57 -0600
Message-ID: <62ddb5a5-2242-abea-7702-fbf7377d8a1e@gmail.com>
References: <1502399795-25660-1-git-send-email-girish.moodalbail@oracle.com>
 <CAJieiUjYggf3zNzwBMFq7zUm+RrZokZ7oNpuz-Hinec=0OSGzA@mail.gmail.com>
 <20170811183957.47f418e6@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Girish Moodalbail <girish.moodalbail@oracle.com>,
        pravin shelar <pshelar@ovn.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Matthias Schiffer <mschiffer@universe-factory.net>
To: Jiri Benc <jbenc@redhat.com>,
        Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:35665 "EHLO
        mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753655AbdHKQ5A (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Aug 2017 12:57:00 -0400
Received: by mail-pf0-f180.google.com with SMTP id t86so18031810pfe.2
        for <netdev@vger.kernel.org>; Fri, 11 Aug 2017 09:57:00 -0700 (PDT)
In-Reply-To: <20170811183957.47f418e6@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/11/17 10:39 AM, Jiri Benc wrote:
>>> +       if (!data) {
>>> +               NL_SET_ERR_MSG(extack,
>>> +                              "Not enough attributes provided to perform the operation");
>>>                 return -EINVAL;
>>> +       }
>> "not enough attributes"
> You're missing part of the sentence.
> 

I would argue none of those messages are sufficient. The message should
tell the user what is missing.

What is the point of the !data check anyway? Based on the rest of the
validate function neither IFLA_VXLAN_ID or IFLA_VXLAN_PORT_RANGE are
required attributes.
