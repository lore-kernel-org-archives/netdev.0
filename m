From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next V3 2/2] rtnl: Add support for netdev event
 attribute to link messages
Date: Tue, 2 May 2017 15:57:48 -0600
Message-ID: <4b94bb74-a4cf-e491-7636-483a1849aea6@cumulusnetworks.com>
References: <1492795881-11914-1-git-send-email-vyasevic@redhat.com>
 <1492795881-11914-3-git-send-email-vyasevic@redhat.com>
 <877efb54-2aef-4d1e-c0b4-2ce6aa6562df@cumulusnetworks.com>
 <7b5396ae-0cf3-2a1e-9c49-5d6f031adf58@redhat.com>
 <760db30a-859a-a365-e0f3-69a4433ef9bf@cumulusnetworks.com>
 <20170428163804.GH1886@nanopsycho.orion>
 <00ddfbb9-9cf7-026d-562b-1b7a4a7129d3@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Vladislav Yasevich <vyasevich@gmail.com>, netdev@vger.kernel.org,
        roopa <roopa@cumulusnetworks.com>
To: vyasevic@redhat.com, Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:35772 "EHLO
        mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751274AbdEBV5v (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 2 May 2017 17:57:51 -0400
Received: by mail-pf0-f176.google.com with SMTP id v14so3240472pfd.2
        for <netdev@vger.kernel.org>; Tue, 02 May 2017 14:57:51 -0700 (PDT)
In-Reply-To: <00ddfbb9-9cf7-026d-562b-1b7a4a7129d3@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/1/17 7:35 AM, Vlad Yasevich wrote:
> So, it looks like the notifier might be there to account for the ioctl/sysfs
> interfaces.

hmmm... I guess we have to leave it then.

> 
> Additionally, the message is not generated from do_setlink() if the devices is
> down, so notifier accounts for that as well.
> 
> I guess, basic question is whether data carried in NETDEV_CHANGEINFODATA is useful
> to user space?  If yes (I can possibly see some managements apps that might be interested
> in it), then we shouldn't just remove it.  Possible solutions to eliminate duplicates
> would be to move the notifier call into non-rtnl code paths...
> 
> Also, may be netdev_state_change() should call rtmsg_ifinfo() unconditionally?

Link up will generate a message, so userspace gets notified at some point.
